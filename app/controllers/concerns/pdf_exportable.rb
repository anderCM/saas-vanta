module PdfExportable
  extend ActiveSupport::Concern

  private

  def generate_pdf(record, template:)
    html = render_to_string(template: template, layout: "layouts/pdf")
    pdf_data = WickedPdf.new.pdf_from_string(html,
      page_size: "A4",
      margin: { top: 10, bottom: 10, left: 10, right: 10 },
      print_media_type: true
    )
    send_data pdf_data,
      filename: "#{record.enterprise.comercial_name.parameterize}-#{record.code}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end
end
