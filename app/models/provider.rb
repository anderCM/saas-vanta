class Provider < ApplicationRecord
  # Associations
  belongs_to :enterprise

  # Validations
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :validate_phone_number
  validate :validate_tax_id

  private

  def validate_phone_number
    Peru::PhoneValidator.new(attributes: [ :phone_number ], allow_blank: true).validate_each(self, :phone_number, phone_number)
  end

  def validate_tax_id
    Peru::TaxIdValidator.new(attributes: [ :tax_id ], allow_blank: true).validate_each(self, :tax_id, tax_id)
  end
end
