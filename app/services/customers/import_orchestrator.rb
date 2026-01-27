module Customers
  class ImportOrchestrator < BaseService
    # Maps Excel column names to Customer attributes
    COLUMN_MAPPING = {
      nombre: :name,
      tipo_documento: :tax_id_type,
      numero_documento: :tax_id,
      email: :email,
      telefono: :phone_number,
      direccion: :address,
      limite_credito: :credit_limit,
      dias_credito: :payment_terms
    }.freeze

    REQUIRED_COLUMNS = [ :nombre ].freeze

    def initialize(bulk_import:)
      super()
      @bulk_import = bulk_import
      @enterprise = bulk_import.enterprise
    end

    def call
      @bulk_import.mark_as_processing!

      # Parse Excel file
      parser = parse_excel
      return handle_parser_error(parser) unless parser.valid?

      # Validate headers
      return handle_missing_columns(parser.headers) unless valid_headers?(parser.headers)

      # Transform rows to records with metadata
      records = transform_rows(parser.rows)

      # Update total rows
      @bulk_import.update!(total_rows: records.size)

      # Delegate creation to the service
      creator = Customers::CreateCustomers.new(records: records, enterprise: @enterprise)
      creator.call

      # Update bulk import status
      update_bulk_import_status(creator)

      creator.valid? ? set_as_valid! : set_as_invalid!
    rescue StandardError => e
      @bulk_import.mark_as_failed!(e.message)
      add_error(e.message)
      set_as_invalid!
    end

    private

    def parse_excel
      parser = BulkImports::ExcelParser.new(
        file: @bulk_import.file,
        header_row: 1,
        data_start_row: 2
      )
      parser.call
      parser
    end

    def handle_parser_error(parser)
      error_msg = parser.errors.join(", ")
      @bulk_import.mark_as_failed!(error_msg)
      add_error(error_msg)
      set_as_invalid!
    end

    def valid_headers?(headers)
      REQUIRED_COLUMNS.all? { |col| headers.include?(col) }
    end

    def handle_missing_columns(headers)
      missing = REQUIRED_COLUMNS.reject { |col| headers.include?(col) }
      error_msg = "Columnas requeridas faltantes: #{missing.join(', ')}"
      @bulk_import.mark_as_failed!(error_msg)
      add_error(error_msg)
      set_as_invalid!
    end

    def transform_rows(rows)
      rows.map { |row| transform_single_row(row) }
    end

    def transform_single_row(row)
      row_number = row[:_row_number]
      customer_attrs = build_customer_attributes(row)

      { attrs: customer_attrs, meta: { row: row_number } }
    end

    def build_customer_attributes(row)
      attrs = {}

      COLUMN_MAPPING.each do |excel_col, attr_name|
        value = row[excel_col]
        attrs[attr_name] = normalize_value(attr_name, value)
      end

      # Set defaults
      attrs[:tax_id_type] ||= "no_document"
      attrs[:credit_limit] ||= 0.0
      attrs[:payment_terms] ||= 0

      attrs.compact
    end

    def normalize_value(attr_name, value)
      return nil if value.blank?

      case attr_name
      when :tax_id
        value.to_s.strip.gsub(/\D/, "")
      when :phone_number
        value.to_s.strip.gsub(/\D/, "")
      when :tax_id_type
        normalize_tax_id_type(value)
      when :credit_limit
        value.to_s.gsub(",", ".").to_f
      when :payment_terms
        value.to_i
      else
        value.to_s.strip
      end
    end

    def normalize_tax_id_type(value)
      mapping = {
        "ruc" => "ruc",
        "dni" => "dni",
        "ninguno" => "no_document",
        "no_document" => "no_document",
        "" => "no_document"
      }
      mapping[value.to_s.downcase.strip] || "no_document"
    end

    def update_bulk_import_status(creator)
      all_errors = format_creator_errors(creator.errors)

      @bulk_import.mark_as_completed!(
        successful: creator.created_count,
        failed: creator.failed_count,
        errors: all_errors
      )
    end

    def format_creator_errors(errors)
      errors.map do |error|
        {
          row: error[:row],
          name: error[:name],
          error: error[:errors]&.join(", ") || error[:error]
        }
      end
    end
  end
end
