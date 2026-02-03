module ProvidersHelper
  def format_tax_id(tax_id)
    return "-" if tax_id.blank?

    # Format RUC (11 digits) or DNI (8 digits)
    if tax_id.length == 11
      "RUC: #{tax_id}"
    elsif tax_id.length == 8
      "DNI: #{tax_id}"
    else
      tax_id
    end
  end

  def format_phone_number(phone)
    return "-" if phone.blank?
    phone
  end
end
