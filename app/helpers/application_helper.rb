module ApplicationHelper
  include Pagy::Frontend

  # Sidebar navigation link helper
  # @param name [String] The link text
  # @param path [String] The link path
  # @param icon [String] The Lucide icon name
  def sidebar_link_to(name, path, icon:)
    is_active = current_page?(path) || (path != root_path && request.path.start_with?(path.to_s))

    link_to path, class: "sidebar-nav-item #{is_active ? 'active' : ''}" do
      content_tag(:span, class: "sidebar-nav-icon") do
        sidebar_icon(icon)
      end +
      content_tag(:span, name, class: "sidebar-nav-text", data: { sidebar_target: "collapsible" })
    end
  end

  # Render a Lucide icon as inline SVG
  # @param name [String] The icon name
  # @param options [Hash] Additional options (size, class, color)
  def sidebar_icon(name, options = {})
    icons = {
      "layout-dashboard" => '<path stroke-linecap="round" stroke-linejoin="round" d="M3 3h7v9H3V3zm11 0h7v5h-7V3zm0 9h7v9h-7v-9zM3 16h7v5H3v-5z"/>',
      "package" => '<path stroke-linecap="round" stroke-linejoin="round" d="M16.5 9.4l-9-5.19M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><path stroke-linecap="round" stroke-linejoin="round" d="M3.27 6.96L12 12.01l8.73-5.05M12 22.08V12"/>',
      "truck" => '<path stroke-linecap="round" stroke-linejoin="round" d="M1 3h15v13H1V3zm15 8h4l3 3v5h-7v-8zm3 8a2 2 0 100-4 2 2 0 000 4zm-12 0a2 2 0 100-4 2 2 0 000 4z"/>',
      "users" => '<path stroke-linecap="round" stroke-linejoin="round" d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8zm14 10v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>',
      "building-2" => '<path stroke-linecap="round" stroke-linejoin="round" d="M6 22V4a2 2 0 012-2h8a2 2 0 012 2v18zm-6 0h24M10 6h4m-4 4h4m-4 4h4"/>',
      "settings" => '<circle cx="12" cy="12" r="3"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>',
      "moon" => '<path stroke-linecap="round" stroke-linejoin="round" d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/>',
      "sun" => '<circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>',
      "log-out" => '<path stroke-linecap="round" stroke-linejoin="round" d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/>',
      "chevrons-left" => '<path stroke-linecap="round" stroke-linejoin="round" d="M11 17l-5-5 5-5M18 17l-5-5 5-5"/>',
      "chevrons-right" => '<path stroke-linecap="round" stroke-linejoin="round" d="M13 17l5-5-5-5M6 17l5-5-5-5"/>',
      "x" => '<path stroke-linecap="round" stroke-linejoin="round" d="M18 6L6 18M6 6l12 12"/>',
      "menu" => '<path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>'
    }

    css_class = options[:class] || "w-5 h-5"
    stroke_color = options[:stroke] || "currentColor"

    content_tag(:svg, icons[name]&.html_safe, class: css_class, fill: "none", viewBox: "0 0 24 24", stroke: stroke_color, stroke_width: "2")
  end
end
