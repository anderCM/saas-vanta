class Peru::PhoneValidator < ActiveModel::EachValidator
  VALID_FORMATS = [
    /\A9\d{8}\z/,         # Cellphone with 9 digits starting with 9
    /\A\+519\d{8}\z/,     # Cellphone with country code and +
    /\A519\d{8}\z/        # Cellphone with country code without +
  ].freeze

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    cleaned = value.to_s.gsub(/[\s\-\(\)]/, "")
    unless VALID_FORMATS.any? { |format| cleaned.match?(format) }
      record.errors.add(
        :base,
        options[:message] || "El Número de teléfono debe tener cualquiera de los siguientes formatos: 987654321, +51987654321, 51987654321"
      )
    end
  end
end
