module BulkImports
  class TemplateGenerator < BaseService
    # Number of rows to apply dropdown validation (adjust as needed)
    DROPDOWN_ROW_COUNT = 1000

    TEMPLATES = {
      "Product" => {
        headers: [
          "Nombre",
          "SKU",
          "Descripcion",
          "Tipo Origen",
          "Unidad",
          "Unidades por Paquete",
          "Precio Compra",
          "Precio Venta Contado",
          "Precio Venta Credito",
          "Stock",
          "Estado",
          "RUC Proveedor"
        ],
        examples: [
          [
            "Producto de Prueba 1",
            "SKU-TEST-001",
            "Descripcion de ejemplo",
            "Comprado",
            "Unidad",
            "1",
            "10.00",
            "15.00",
            "18.00",
            "100",
            "Activo",
            "20123456789"
          ],
          [
            "Producto Test 2",
            "SKU-TEST-002",
            "Otra descripcion de prueba",
            "Manufacturado",
            "Kilogramo",
            "1",
            "25.50",
            "35.00",
            "40.00",
            "50",
            "Activo",
            ""
          ]
        ],
        column_widths: [ 30, 15, 40, 18, 15, 20, 15, 20, 20, 10, 15, 15 ],
        # Dropdowns: column index (0-based) => options with display labels
        dropdowns: {
          3 => { # Tipo Origen
            name: "TipoOrigen",
            options: [
              { label: "Comprado", value: "purchased" },
              { label: "Manufacturado", value: "manufactured" },
              { label: "Otro", value: "other" }
            ]
          },
          4 => { # Unidad
            name: "Unidad",
            options: [
              { label: "Kilogramo", value: "kg" },
              { label: "Gramo", value: "g" },
              { label: "Litro", value: "lt" },
              { label: "Mililitro", value: "ml" },
              { label: "Unidad", value: "un" },
              { label: "Centilitro", value: "cl" }
            ]
          },
          10 => { # Estado
            name: "Estado",
            options: [
              { label: "Activo", value: "active" },
              { label: "Inactivo", value: "inactive" },
              { label: "Descontinuado", value: "discontinued" }
            ]
          }
        },
        instructions: [
          "INSTRUCCIONES:",
          "1. Las primeras 2 filas de ejemplo seran ignoradas automaticamente (contienen 'prueba' o 'test')",
          "2. Agregue sus productos debajo de las filas de ejemplo",
          "3. Las columnas 'Tipo Origen', 'Unidad' y 'Estado' tienen listas desplegables - seleccione una opcion",
          "4. RUC Proveedor: Obligatorio solo si Tipo Origen es 'Comprado'",
          "5. Los precios deben usar punto (.) como separador decimal"
        ]
      },
      "Provider" => {
        headers: [
          "Nombre",
          "RUC/DNI",
          "Email",
          "Telefono"
        ],
        examples: [
          [
            "Proveedor de Prueba 1",
            "20123456789",
            "prueba@ejemplo.com",
            "987654321"
          ],
          [
            "Proveedor Test 2",
            "12345678",
            "test@ejemplo.com",
            "912345678"
          ]
        ],
        column_widths: [ 35, 15, 30, 15 ],
        dropdowns: {},
        instructions: [
          "INSTRUCCIONES:",
          "1. Las primeras 2 filas de ejemplo seran ignoradas automaticamente",
          "2. Agregue sus proveedores debajo de las filas de ejemplo",
          "3. RUC/DNI: 11 digitos para RUC, 8 digitos para DNI",
          "4. Telefono: 9 digitos para celular"
        ]
      },
      "Customer" => {
        headers: [
          "Nombre",
          "Tipo Documento",
          "Numero Documento",
          "Email",
          "Telefono",
          "Direccion",
          "Limite Credito",
          "Dias Credito"
        ],
        examples: [
          [
            "Cliente de Prueba 1",
            "RUC",
            "20123456789",
            "prueba@ejemplo.com",
            "987654321",
            "Av. Principal 123",
            "5000.00",
            "30"
          ],
          [
            "Cliente Test 2",
            "DNI",
            "12345678",
            "test@ejemplo.com",
            "912345678",
            "Jr. Secundario 456",
            "1000.00",
            "15"
          ]
        ],
        column_widths: [ 30, 18, 18, 25, 15, 35, 15, 15 ],
        dropdowns: {
          1 => { # Tipo Documento
            name: "TipoDocumento",
            options: [
              { label: "RUC", value: "ruc" },
              { label: "DNI", value: "dni" },
              { label: "Ninguno", value: "no_document" }
            ]
          }
        },
        instructions: [
          "INSTRUCCIONES:",
          "1. Las primeras 2 filas de ejemplo seran ignoradas automaticamente (contienen 'prueba' o 'test')",
          "2. Agregue sus clientes debajo de las filas de ejemplo",
          "3. Tipo Documento: RUC (11 digitos), DNI (8 digitos), o Ninguno",
          "4. Limite Credito: Monto maximo de credito permitido (use punto como decimal)",
          "5. Dias Credito: Plazo de pago en dias (0 = solo contado)"
        ]
      }
    }.freeze

    def initialize(resource_type:)
      super()
      @resource_type = resource_type
      @template_config = TEMPLATES[@resource_type]
    end

    attr_reader :package

    def call
      unless @template_config
        add_error("Tipo de recurso no soportado: #{@resource_type}")
        return set_as_invalid!
      end

      generate_excel
      set_as_valid!
    rescue StandardError => e
      add_error("Error generando plantilla: #{e.message}")
      set_as_invalid!
    end

    private

    def generate_excel
      @package = Axlsx::Package.new
      workbook = @package.workbook

      styles = define_styles(workbook)

      options_sheet = create_options_sheet(workbook) if has_dropdowns?

      workbook.add_worksheet(name: "Datos") do |sheet|
        add_header_row(sheet, styles)
        add_example_rows(sheet, styles)
        set_column_widths(sheet)
        apply_dropdowns(sheet, options_sheet) if has_dropdowns?
      end

      workbook.add_worksheet(name: "Instrucciones") do |sheet|
        add_instructions(sheet, styles)
      end
    end

    def define_styles(workbook)
      {
        header: workbook.styles.add_style(
          bg_color: "10B981",
          fg_color: "FFFFFF",
          b: true,
          alignment: { horizontal: :center, vertical: :center },
          border: { style: :thin, color: "059669" }
        ),
        example: workbook.styles.add_style(
          bg_color: "ECFDF5",
          fg_color: "065F46",
          i: true,
          alignment: { vertical: :center },
          border: { style: :thin, color: "D1FAE5" }
        ),
        instruction_title: workbook.styles.add_style(
          b: true,
          sz: 14,
          fg_color: "10B981"
        ),
        instruction: workbook.styles.add_style(
          sz: 11
        ),
        options_header: workbook.styles.add_style(
          bg_color: "374151",
          fg_color: "FFFFFF",
          b: true
        )
      }
    end

    def add_header_row(sheet, styles)
      sheet.add_row(@template_config[:headers], style: styles[:header], height: 25)
    end

    def add_example_rows(sheet, styles)
      @template_config[:examples].each do |example|
        sheet.add_row(example, style: styles[:example])
      end
    end

    def set_column_widths(sheet)
      @template_config[:column_widths].each_with_index do |width, index|
        sheet.column_info[index].width = width
      end
    end

    def add_instructions(sheet, styles)
      @template_config[:instructions].each_with_index do |instruction, index|
        style = index.zero? ? styles[:instruction_title] : styles[:instruction]
        sheet.add_row([ instruction ], style: style)
      end

      add_dropdown_legend(sheet, styles) if has_dropdowns?
    end

    def add_dropdown_legend(sheet, styles)
      sheet.add_row([])
      sheet.add_row([ "VALORES PERMITIDOS:" ], style: styles[:instruction_title])

      dropdowns.each do |_col_index, config|
        options_text = config[:options].map { |opt| "#{opt[:label]}" }.join(", ")
        sheet.add_row([ "#{config[:name]}: #{options_text}" ], style: styles[:instruction])
      end
    end

    # --- Dropdown functionality ---

    def has_dropdowns?
      dropdowns.present?
    end

    def dropdowns
      @template_config[:dropdowns] || {}
    end

    def create_options_sheet(workbook)
      options_sheet = nil

      workbook.add_worksheet(name: "Opciones") do |sheet|
        options_sheet = sheet

        max_options = dropdowns.values.map { |c| c[:options].size }.max

        headers = dropdowns.values.map { |c| c[:name] }
        sheet.add_row(headers)

        max_options.times do |row_index|
          row_values = dropdowns.values.map do |config|
            config[:options][row_index]&.dig(:label) || ""
          end
          sheet.add_row(row_values)
        end

        dropdowns.size.times do |i|
          sheet.column_info[i].width = 20
        end
      end

      options_sheet.state = :very_hidden

      options_sheet
    end

    def apply_dropdowns(data_sheet, options_sheet)
      return unless options_sheet

      dropdowns.each_with_index do |(col_index, config), dropdown_index|
        options_count = config[:options].size
        options_col_letter = column_letter(dropdown_index)

        formula = "Opciones!$#{options_col_letter}$2:$#{options_col_letter}$#{options_count + 1}"

        data_col_letter = column_letter(col_index)
        start_row = 4
        end_row = start_row + DROPDOWN_ROW_COUNT

        data_sheet.add_data_validation(
          "#{data_col_letter}#{start_row}:#{data_col_letter}#{end_row}",
          type: :list,
          formula1: formula,
          hideDropDown: false,
          showErrorMessage: true,
          errorTitle: "Valor no valido",
          error: "Por favor seleccione un valor de la lista.",
          errorStyle: :stop,
          showInputMessage: true,
          promptTitle: config[:name],
          prompt: "Seleccione una opcion de la lista"
        )
      end
    end

    def column_letter(index)
      result = ""
      while index >= 0
        result = ((index % 26) + 65).chr + result
        index = (index / 26) - 1
      end
      result
    end
  end
end
