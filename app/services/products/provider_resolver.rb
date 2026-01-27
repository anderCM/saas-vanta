module Products
  class ProviderResolver < BaseService
    def initialize(enterprise:)
      super()
      @enterprise = enterprise
      @cache = {}
    end

    # Resolve a single provider by tax_id (RUC/DNI)
    # Returns provider_id or nil
    def resolve(tax_id)
      return nil if tax_id.blank?

      normalized_tax_id = normalize_tax_id(tax_id)
      return nil if normalized_tax_id.blank?

      # Check cache first
      return @cache[normalized_tax_id] if @cache.key?(normalized_tax_id)

      # Query database
      provider = @enterprise.providers.find_by(tax_id: normalized_tax_id)
      @cache[normalized_tax_id] = provider&.id

      provider&.id
    end

    # Preload providers for a batch of tax_ids (optimization)
    def preload(tax_ids)
      normalized_ids = tax_ids.map { |id| normalize_tax_id(id) }.compact.uniq

      providers = @enterprise.providers
                             .where(tax_id: normalized_ids)
                             .pluck(:tax_id, :id)

      providers.each do |tax_id, id|
        @cache[tax_id] = id
      end
    end

    # Check if a tax_id exists
    def exists?(tax_id)
      resolve(tax_id).present?
    end

    def call
      # This service doesn't need a main call method
      # It's used as a helper service
      set_as_valid!
    end

    private

    def normalize_tax_id(tax_id)
      return nil if tax_id.blank?
      tax_id.to_s.strip.gsub(/\D/, "")
    end
  end
end
