class PurchaseOrder < ApplicationRecord
  # Associations
  belongs_to :enterprise
  belongs_to :provider
  belongs_to :created_by, class_name: "User"
  belongs_to :destination, class_name: "Ubigeo", optional: true
  belongs_to :customer, optional: true

  has_many :items, class_name: "PurchaseOrderItem", dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :code, presence: true, uniqueness: { scope: :enterprise_id }
  validates :issue_date, presence: true
  validates :status, presence: true

  # Enums
  enum :status, {
    draft: "draft",
    confirmed: "confirmed",
    received: "received",
    cancelled: "cancelled"
  }

  # Callbacks
  before_save :calculate_totals

  # Instance methods
  def can_edit?
    draft?
  end

  def can_confirm?
    draft? && items.any?
  end

  def can_receive?
    confirmed?
  end

  def can_cancel?
    draft? || confirmed?
  end

  def confirm!
    return false unless can_confirm?

    update!(status: :confirmed)
  end

  def receive!
    return false unless can_receive?

    transaction do
      update!(status: :received)
      update_product_stock!
    end
  end

  def cancel!
    return false unless can_cancel?

    update!(status: :cancelled)
  end

  def status_badge_class
    case status
    when "draft" then "badge-secondary"
    when "confirmed" then "badge-info"
    when "received" then "badge-success"
    when "cancelled" then "badge-destructive"
    else "badge-secondary"
    end
  end

  def status_label
    {
      "draft" => "Borrador",
      "confirmed" => "Confirmada",
      "received" => "Recibida",
      "cancelled" => "Cancelada"
    }[status] || status.humanize
  end

  private

  def calculate_totals
    self.total = items.sum { |item| item.total || 0 }
    self.subtotal = PeruTax.base_amount(total)
    self.tax = PeruTax.extract_igv(total)
  end

  def update_product_stock!
    items.includes(:product).find_each do |item|
      product = item.product
      current_stock = product.stock || 0
      product.update!(stock: current_stock + item.quantity)
    end
  end
end
