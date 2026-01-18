class Providers::CreateNewProviders < BaseService
  BATCH_SIZE = 1_000

  # providers is not a collection of Provider model
  # It is a collection of hashes to be inserted into the database
  def initialize(providers:, enterprise:)
    super()
    @providers = providers
    @enterprise = enterprise
  end

  def call
    @providers.each_slice(BATCH_SIZE) do |batch|
      batch.each do |attrs|
        provider = Provider.new(attrs.merge(enterprise: @enterprise))

        unless provider.save
          @errors << { name: provider.name, errors: provider.errors.full_messages }
        end
      end
    end

    return set_as_valid! if @errors.empty?

    set_as_invalid!
  rescue ActiveRecord::ActiveRecordError => e
    add_error(e.message)
    set_as_invalid!
  end
end
