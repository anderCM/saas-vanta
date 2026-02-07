class Product < ApplicationRecord
  # Asociations
  belongs_to :enterprise
  belongs_to :provider, optional: true
  has_many :purchase_order_items, dependent: :restrict_with_error
  has_many :customer_quote_items, dependent: :restrict_with_error
  has_many :sale_items, dependent: :restrict_with_error

  # Normalizations
  normalizes :sku, with: ->(value) { value.strip.presence }
  validates :units_per_package, numericality: { greater_than: 0 }, allow_nil: true

  # Validations
  validates :name, presence: true
  validates :buy_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_cash_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_credit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_stock
  validate :provider_presence_based_on_source

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

  enum :source_type, {
    purchased: "purchased",
    manufactured: "manufactured",
    other: "other"
  }

  def combobox_display
    sku.present? ? "#{name} (#{sku})" : name
  end

  private

  def validate_stock
    return unless stock.present?
    errors_msg = "El stock debe ser un número entero no negativo"

    raw_value = stock_before_type_cast
    unless raw_value.is_a?(Integer) || (raw_value.is_a?(String) && raw_value.match?(/\A\d+\z/))
      errors.add(:base, errors_msg)
      return
    end

    if stock.negative?
      errors.add(:base, errors_msg)
    end
  end

  def provider_presence_based_on_source
    return unless source_type == "purchased"

    errors.add(:base, "Proveedor es obligatorio para productos comprados") if provider.nil?
  end
end
