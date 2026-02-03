module BulkImports
  class ExcelParser < BaseService
    # Rows containing these words in any column will be skipped (case insensitive)
    SKIP_KEYWORDS = %w[prueba test ejemplo example].freeze

    def initialize(file:, header_row: 1, data_start_row: 2)
      super()
      @file = file
      @header_row = header_row
      @data_start_row = data_start_row
      @rows = []
      @headers = []
      @tempfile = nil
    end

    attr_reader :rows, :headers

    def call
      spreadsheet = open_spreadsheet
      return set_as_invalid! unless spreadsheet

      # Select the correct sheet (prefer "Datos" if exists, otherwise first sheet)
      select_data_sheet(spreadsheet)

      parse_headers(spreadsheet)
      parse_data_rows(spreadsheet)

      set_as_valid!
    rescue StandardError => e
      add_error("Error al procesar el archivo: #{e.message}")
      set_as_invalid!
    ensure
      cleanup_tempfile
    end

    private

    def open_spreadsheet
      if @file.is_a?(ActionDispatch::Http::UploadedFile) || @file.is_a?(Rack::Test::UploadedFile)
        open_from_uploaded_file
      elsif @file.is_a?(ActiveStorage::Attached::One) || @file.is_a?(ActiveStorage::Attachment)
        open_from_active_storage
      elsif @file.respond_to?(:blob) || @file.respond_to?(:attachment)
        # Handle other ActiveStorage-like objects
        open_from_active_storage
      else
        add_error("Tipo de archivo no soportado: #{@file.class}")
        nil
      end
    end

    def open_from_uploaded_file
      case File.extname(@file.original_filename).downcase
      when ".xlsx"
        Roo::Excelx.new(@file.tempfile.path)
      when ".xls"
        Roo::Excel.new(@file.tempfile.path)
      when ".csv"
        Roo::CSV.new(@file.tempfile.path)
      else
        add_error("Formato de archivo no soportado. Use .xlsx, .xls o .csv")
        nil
      end
    end

    def open_from_active_storage
      # Handle both ActiveStorage::Attached::One and ActiveStorage::Attachment
      attachment = @file.is_a?(ActiveStorage::Attached::One) ? @file.attachment : @file

      unless attachment&.blob
        add_error("No se encontró el archivo adjunto")
        return nil
      end

      extension = attachment.filename.extension.downcase

      # Create a persistent tempfile that won't be deleted until we're done
      @tempfile = Tempfile.new([ "bulk_import", ".#{extension}" ])
      @tempfile.binmode

      # Download the blob content to our tempfile
      @tempfile.write(attachment.blob.download)
      @tempfile.flush  # Ensure data is written to disk before Roo reads it
      @tempfile.rewind

      case extension
      when "xlsx"
        Roo::Excelx.new(@tempfile.path)
      when "xls"
        Roo::Excel.new(@tempfile.path)
      when "csv"
        Roo::CSV.new(@tempfile.path)
      else
        add_error("Formato de archivo no soportado. Use .xlsx, .xls o .csv")
        nil
      end
    end

    def cleanup_tempfile
      return unless @tempfile

      @tempfile.close
      @tempfile.unlink
    rescue StandardError
      # Ignore cleanup errors
    end

    def select_data_sheet(spreadsheet)
      # For CSV files, there's only one "sheet"
      return if spreadsheet.is_a?(Roo::CSV)

      # Prefer "Datos" sheet if it exists (our template format)
      if spreadsheet.sheets.include?("Datos")
        spreadsheet.default_sheet = "Datos"
      else
        # Otherwise use the first visible sheet (skip hidden sheets like "Opciones")
        visible_sheet = spreadsheet.sheets.find { |name| name != "Opciones" }
        spreadsheet.default_sheet = visible_sheet if visible_sheet
      end
    end

    def parse_headers(spreadsheet)
      raw_headers = spreadsheet.row(@header_row)
      @headers = raw_headers.map { |h| normalize_header(h) }
    end

    def parse_data_rows(spreadsheet)
      (@data_start_row..spreadsheet.last_row).each do |row_num|
        raw_row = spreadsheet.row(row_num)

        # Skip empty rows
        next if raw_row.all?(&:blank?)

        # Skip rows with test/example keywords
        next if should_skip_row?(raw_row)

        row_hash = build_row_hash(raw_row, row_num)
        @rows << row_hash
      end
    end

    def should_skip_row?(raw_row)
      raw_row.any? do |cell|
        next false if cell.blank?
        cell_value = cell.to_s.downcase.strip
        SKIP_KEYWORDS.any? { |keyword| cell_value.include?(keyword) }
      end
    end

    def build_row_hash(raw_row, row_num)
      hash = { _row_number: row_num }
      @headers.each_with_index do |header, index|
        next if header.blank?
        hash[header] = sanitize_value(raw_row[index])
      end
      hash
    end

    def normalize_header(header)
      return nil if header.blank?
      header.to_s
            .strip
            .downcase
            .gsub(/\s+/, "_")
            .gsub(/[^a-z0-9_]/, "")
            .to_sym
    end

    def sanitize_value(value)
      return nil if value.blank?
      return value.strip if value.is_a?(String)
      value
    end
  end
end
