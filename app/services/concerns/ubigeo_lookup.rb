module UbigeoLookup
  extend ActiveSupport::Concern

  included do
    def initialize_ubigeo_cache
      @ubigeo_cache = {}
    end
  end

  # Resolves ubigeo_id from departamento, provincia, distrito names
  # Uses caching to avoid repeated database queries for the same location
  #
  # @param departamento [String] Department name
  # @param provincia [String] Province name
  # @param distrito [String] District name
  #
  # @return [Integer, nil] The ubigeo_id or nil if not found
  def find_ubigeo_id(departamento, provincia, distrito)
    return nil if distrito.blank?

    cache_key = "#{departamento}|#{provincia}|#{distrito}".downcase
    return @ubigeo_cache[cache_key] if @ubigeo_cache.key?(cache_key)

    ubigeo = Ubigeo.districts
                   .joins("INNER JOIN ubigeos provinces ON ubigeos.parent_id = provinces.id")
                   .joins("INNER JOIN ubigeos departments ON provinces.parent_id = departments.id")
                   .where("LOWER(ubigeos.name) = ?", distrito.downcase)
                   .where("LOWER(provinces.name) = ?", provincia.to_s.downcase)
                   .where("LOWER(departments.name) = ?", departamento.to_s.downcase)
                   .first

    @ubigeo_cache[cache_key] = ubigeo&.id
  end

  # Extracts ubigeo data from row attributes and resolves to ubigeo_id
  # Expects temporary keys like :_departamento, :_provincia, :_distrito
  #
  # @param ubigeo_data [Hash] Hash with :_departamento, :_provincia, :_distrito keys
  # @return [Integer, nil] The ubigeo_id or nil if not found
  def resolve_ubigeo_from_data(ubigeo_data)
    return nil unless ubigeo_data.values.any?(&:present?)

    find_ubigeo_id(
      ubigeo_data[:_departamento],
      ubigeo_data[:_provincia],
      ubigeo_data[:_distrito]
    )
  end
end
