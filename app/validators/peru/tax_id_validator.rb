class Peru::TaxIdValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    unless value.to_s.match?(/\A(10|20)\d{9}\z/)
      record.errors.add(
        :base,
        options[:message] || "El RUC debe ser un número válido de 11 dígitos (empezar con 10 o 20)"
      )
    end
  end
end
