module ProductsHelper
  def render_status_badge(status)
    classes = case status
    when "active"
      "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400"
    when "inactive"
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400"
    when "discontinued"
      "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400"
    end

    label = case status
    when "active" then "Activo"
    when "inactive" then "Inactivo"
    when "discontinued" then "Descontinuado"
    else status.humanize
    end

    content_tag(:span, label, class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{classes}")
  end

  def source_type_label(source_type)
    case source_type
    when "purchased" then "Comprado"
    when "manufactured" then "Manufacturado"
    when "other" then "Otro"
    else source_type.humanize
    end
  end

  def unit_label(unit)
    case unit
    when "kg" then "Kilogramo (kg)"
    when "g" then "Gramo (g)"
    when "lt" then "Litro (lt)"
    when "ml" then "Mililitro (ml)"
    when "un" then "Unidad (un)"
    when "cl" then "Centilitro (cl)"
    else unit
    end
  end
end
