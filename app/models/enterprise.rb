class Enterprise < ApplicationRecord
  # Asociations
  has_many :user_enterprises
  has_many :users, through: :user_enterprises
  has_many :providers, dependent: :destroy
  has_many :products, dependent: :destroy

  # Callbacks
  before_validation :generate_subdomain, on: :create
  before_validation :set_enterprise_type

  # Validations
  validates :comercial_name, :enterprise_type, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :validate_phone_number
  validate :validate_tax_id

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

  def set_enterprise_type
    self.enterprise_type = tax_id.present? ? :formal : :informal
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

  def validate_phone_number
    Peru::PhoneValidator.new(attributes: [ :phone_number ], allow_blank: true).validate_each(self, :phone_number, phone_number)
  end

  def validate_tax_id
    Peru::TaxIdValidator.new(attributes: [ :tax_id ], allow_blank: true).validate_each(self, :tax_id, tax_id)
  end
end
