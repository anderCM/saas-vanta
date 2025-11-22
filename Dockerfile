# syntax = docker/dockerfile:1

# This Dockerfile is designed for production deployment with Kamal
# It follows security best practices with multi-stage builds and non-root user

###########################################
# Stage 1: Base - Minimal runtime dependencies
###########################################
ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install only runtime dependencies (NO git, NO python, NO build tools)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

###########################################
# Stage 2: Build - Build dependencies only
###########################################
FROM base AS build

# Install Node.js 20 LTS (specific version for reproducibility)
ARG NODE_VERSION=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    nodejs \
    build-essential \
    git \
    libpq-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Verify Node.js version
RUN node --version && npm --version

# Install Rails if Gemfile doesn't exist (for initial setup only)
RUN if [ ! -f Gemfile ]; then gem install rails -v '~> 8.0'; fi

# Copy Gemfiles
COPY --link Gemfile* ./

# Install application gems (or skip if no Gemfile yet)
RUN if [ -f Gemfile ]; then bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git; fi

# Copy application code
COPY --link . .

# Precompile bootsnap code for faster boot times (Rails 8 still uses this)
RUN if [ -f bin/rails ]; then bundle exec bootsnap precompile app/ lib/; fi

# Precompile assets with Propshaft (Rails 8 default)
# Note: Rails 8 uses Propshaft instead of Sprockets
RUN if [ -f bin/rails ] && [ -d app/assets ]; then \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile; fi

###########################################
# Stage 3: Final - Minimal production image
###########################################
FROM base

# Create rails user and group (non-root for security)
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Copy built artifacts from build stage (gems and compiled app)
COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

# Create necessary directories and set permissions
RUN mkdir -p /rails/tmp/pids /rails/log /rails/storage && \
    chown -R rails:rails /rails/tmp /rails/log /rails/storage

# Switch to non-root user
USER rails:rails

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000
EXPOSE 3000

# Start server by default (can be overridden by Kamal)
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
