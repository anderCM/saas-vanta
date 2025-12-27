class Product < ApplicationRecord
  # Asociations
  belongs_to :enterprise
  belongs_to :provider

  # Validations
  validates :name, presence: true
  validates :buy_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_cash_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_credit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_stock
  validate :validate_units_per_package

  # Enums
  enum :unit, {
    kg: "kg",
    g: "g",
    lt: "lt",
    ml: "ml",
    un: "un",
    cl: "cl"
  }

  enum :status, {
    active: "active",
    inactive: "inactive",
    discontinued: "discontinued"
  }

  private

  def validate_stock
    return unless stock.present?
    errors_msg = "El stock debe ser un número entero positivo"

    raw_value = stock_before_type_cast
    unless raw_value.is_a?(Integer) || (raw_value.is_a?(String) && raw_value.match?(/\A\d+\z/))
      errors.add(:base, errors_msg)
      return
    end

    unless stock.positive?
      errors.add(:base, errors_msg)
    end
  end

  def validate_units_per_package
    return unless units_per_package.present?
    errors_msg = "El número de unidades por paquete debe ser un número entero positivo"

    raw_value = units_per_package_before_type_cast
    unless raw_value.is_a?(Integer) || (raw_value.is_a?(String) && raw_value.match?(/\A\d+\z/))
      errors.add(:base, errors_msg)
      return
    end

    unless units_per_package.positive?
      errors.add(:base, errors_msg)
    end
  end
end
