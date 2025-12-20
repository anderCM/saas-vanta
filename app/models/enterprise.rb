class Enterprise < ApplicationRecord
  # Asociations
  has_many :user_enterprises
  has_many :users, through: :user_enterprises

  # Callbacks
  before_validation :generate_subdomain, on: :create
  before_validation :set_enterprise_type

  # Validations
  validates :comercial_name, :enterprise_type, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :validate_tax_id
  validate :validate_phone_number

  # Enums
  enum :status, {
      activating: "activating",
      active: "active",
      inactive: "inactive"
  }

  enum :enterprise_type, {
      informal: "informal",
      formal: "formal"
  }

  private

  def validate_tax_id
    return if self.tax_id.nil?

    unless tax_id.to_s.match?(/\A(10|20)\d{9}\z/)
      errors.add(:base, "El RUC debe ser un número válido de 11 dígitos (empezar con 10 o 20)")
    end
  end

  def set_enterprise_type
    self.enterprise_type = tax_id.present? ? :formal : :informal
  end

  def validate_phone_number
    return if phone_number.blank?

    cleaned = phone_number.to_s.gsub(/[\s\-\(\)]/, "")

    valid_formats = [
      /\A9\d{8}\z/,         # Cellphone with 9 digits starting with 9 (987654321)
      /\A\+519\d{8}\z/,     # Cellphone with country code and +(+51987654321)
      /\A519\d{8}\z/        # Cellphone with country code and without + (51987654321)
    ]

    return if valid_formats.any? { |format| cleaned.match?(format) }

    errors.add(:base, "El Número de teléfono debe tener cualquiera de los siguientes formatos: 987654321, +51987654321, 51987654321")
  end

  def generate_subdomain
    return if subdomain.present?
    return if comercial_name.blank?

    pre_subdomain = comercial_name.parameterize
    if Enterprise.exists?(subdomain: pre_subdomain)
      errors.add(:base, "Parece que la empresa ya existe, si crees que se trata de un error, por favor comunícate con el soporte")
      return
    end

    self.subdomain = pre_subdomain
  end

  def validate_formalization_rules
    if tax_id_changed? && tax_id_was.present? && tax_id.nil?
      errors.add(:base, "El RUC no puede eliminarse una vez registrado. Contacte a soporte")
    end

    if tax_id_changed? && tax_id_was.present? && tax_id.present?
      errors.add(:base, "El RUC no puede modificarse una vez registrado. Contacte a soporte")
    end
  end
end
