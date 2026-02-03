module Products
  class ImportOrchestrator < BaseService
    # Maps Excel column names to Product attributes
    COLUMN_MAPPING = {
      nombre: :name,
      sku: :sku,
      descripcion: :description,
      tipo_origen: :source_type,
      unidad: :unit,
      unidades_por_paquete: :units_per_package,
      precio_compra: :buy_price,
      precio_venta_contado: :sell_cash_price,
      precio_venta_credito: :sell_credit_price,
      stock: :stock,
      estado: :status,
      ruc_proveedor: :provider_tax_id
    }.freeze

    REQUIRED_COLUMNS = [ :nombre, :precio_compra, :precio_venta_contado, :precio_venta_credito ].freeze

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

      # Preload providers for optimization
      preload_providers(parser.rows)

      # Transform rows to records with metadata
      records = transform_rows(parser.rows)

      # Update total rows
      @bulk_import.update!(total_rows: records.size)

      # Delegate creation to the service
      creator = Products::CreateProducts.new(records: records, enterprise: @enterprise)
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

    def preload_providers(rows)
      tax_ids = rows.map { |row| row[:ruc_proveedor] }.compact
      @provider_resolver = ProviderResolver.new(enterprise: @enterprise)
      @provider_resolver.preload(tax_ids)
    end

    def transform_rows(rows)
      records = []

      rows.each do |row|
        record = transform_single_row(row)
        records << record if record
      end

      records
    end

    def transform_single_row(row)
      row_number = row[:_row_number]
      product_attrs = build_product_attributes(row)

      # Validate provider for purchased products
      if product_attrs[:source_type] == "purchased" && product_attrs[:provider_id].nil?
        # Add pre-validation error directly to bulk import errors
        @errors << {
          row: row_number,
          name: row[:nombre] || "Sin nombre",
          error: "Proveedor no encontrado para RUC: #{row[:ruc_proveedor]}"
        }
        return nil
      end

      { attrs: product_attrs, meta: { row: row_number } }
    end

    def build_product_attributes(row)
      attrs = {}

      COLUMN_MAPPING.each do |excel_col, attr_name|
        next if attr_name == :provider_tax_id
        value = row[excel_col]
        attrs[attr_name] = normalize_value(attr_name, value)
      end

      # Resolve provider
      if row[:ruc_proveedor].present?
        attrs[:provider_id] = @provider_resolver.resolve(row[:ruc_proveedor])
      end

      # Set defaults
      attrs[:status] ||= "active"
      attrs[:unit] ||= "un"
      attrs[:source_type] ||= "other"

      attrs.compact
    end

    def normalize_value(attr_name, value)
      return nil if value.blank?

      case attr_name
      when :buy_price, :sell_cash_price, :sell_credit_price
        value.to_s.gsub(",", ".").to_f
      when :stock, :units_per_package
        value.to_i
      when :source_type
        normalize_source_type(value)
      when :unit
        normalize_unit(value)
      when :status
        normalize_status(value)
      else
        value.to_s.strip
      end
    end

    def normalize_source_type(value)
      mapping = {
        "comprado" => "purchased",
        "manufacturado" => "manufactured",
        "otro" => "other",
        "purchased" => "purchased",
        "manufactured" => "manufactured",
        "other" => "other"
      }
      mapping[value.to_s.downcase.strip] || "other"
    end

    def normalize_unit(value)
      mapping = {
        "kilogramo" => "kg",
        "gramo" => "g",
        "litro" => "lt",
        "mililitro" => "ml",
        "unidad" => "un",
        "centilitro" => "cl",
        "kg" => "kg",
        "g" => "g",
        "lt" => "lt",
        "ml" => "ml",
        "un" => "un",
        "cl" => "cl"
      }
      mapping[value.to_s.downcase.strip] || "un"
    end

    def normalize_status(value)
      mapping = {
        "activo" => "active",
        "inactivo" => "inactive",
        "descontinuado" => "discontinued",
        "active" => "active",
        "inactive" => "inactive",
        "discontinued" => "discontinued"
      }
      mapping[value.to_s.downcase.strip] || "active"
    end

    def update_bulk_import_status(creator)
      # Combine pre-validation errors with creation errors
      all_errors = @errors + format_creator_errors(creator.errors)

      @bulk_import.mark_as_completed!(
        successful: creator.created_count,
        failed: creator.failed_count + @errors.size,
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
