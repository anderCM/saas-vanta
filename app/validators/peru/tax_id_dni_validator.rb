class Peru::TaxIdDniValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    unless value.to_s.match?(/\A\d{8}\z/)
      record.errors.add(
        :base,
        options[:message] || "El DNI debe ser un número válido de 8 dígitos"
      )
    end
  end
end
