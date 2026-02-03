# Pagy configuration
# See https://ddnexus.github.io/pagy/docs/api/pagy

# Default number of items per page
Pagy::DEFAULT[:limit] = 15

# Default page parameter
Pagy::DEFAULT[:page_param] = :page

# Overflow handling (:empty_page, :last_page, :exception)
Pagy::DEFAULT[:overflow] = :last_page
