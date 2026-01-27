class BulkCreateService < BaseService
  BATCH_SIZE = 1_000

  # @param records [Array<Hash>] Array of attribute hashes or hashes with :attrs and :meta keys
  # @param enterprise [Enterprise] The enterprise to associate records with
  #
  # Records can be in two formats:
  # 1. Simple: [{ name: "...", price: 10 }, { name: "...", price: 20 }]
  # 2. With metadata: [{ attrs: { name: "..." }, meta: { row: 2 } }, ...]
  #
  def initialize(records:, enterprise:)
    super()
    @records = records
    @enterprise = enterprise
    @created_count = 0
    @failed_count = 0
  end

  attr_reader :created_count, :failed_count

  def call
    @records.each_slice(BATCH_SIZE) do |batch|
      batch.each do |record_data|
        attrs, meta = extract_attrs_and_meta(record_data)
        record = model_class.new(build_attributes(attrs))

        if record.save
          @created_count += 1
        else
          @failed_count += 1
          @errors << build_error(record, attrs, meta)
        end
      end
    end

    @errors.empty? ? set_as_valid! : set_as_invalid!
  rescue ActiveRecord::ActiveRecordError => e
    add_error(e.message)
    set_as_invalid!
  end

  private

  # Subclasses must implement this method
  # @return [Class] The ActiveRecord model class
  def model_class
    raise NotImplementedError, "#{self.class} must implement #model_class"
  end

  # Build attributes hash for the record
  # Override in subclasses to add custom attribute transformations
  # @param attrs [Hash] Original attributes
  # @return [Hash] Transformed attributes
  def build_attributes(attrs)
    attrs.merge(enterprise: @enterprise)
  end

  # Extract attributes and metadata from record data
  # Supports both simple format and format with metadata
  # @param record_data [Hash] Record data (simple or with :attrs/:meta keys)
  # @return [Array<Hash, Hash>] [attributes, metadata]
  def extract_attrs_and_meta(record_data)
    if record_data.key?(:attrs)
      [record_data[:attrs], record_data[:meta] || {}]
    else
      [record_data, {}]
    end
  end

  # Build error hash with optional metadata
  # @param record [ActiveRecord::Base] The failed record
  # @param attrs [Hash] Original attributes
  # @param meta [Hash] Optional metadata (e.g., row number)
  # @return [Hash] Error hash
  def build_error(record, attrs, meta)
    error = {
      name: record_identifier(record, attrs),
      errors: record.errors.full_messages
    }

    # Include metadata fields (like row number) if present
    error[:row] = meta[:row] if meta[:row]
    error.merge!(meta.except(:row)) if meta.present?

    error
  end

  # Get a human-readable identifier for error reporting
  # Override in subclasses if the model doesn't have a 'name' attribute
  # @param record [ActiveRecord::Base] The record instance
  # @param attrs [Hash] Original attributes (fallback)
  # @return [String] Identifier for the record
  def record_identifier(record, attrs)
    record.try(:name) || attrs[:name] || "Registro desconocido"
  end
end
