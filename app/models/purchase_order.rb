class PurchaseOrder < ApplicationRecord
  include Documentable

  belongs_to :provider
  belongs_to :sourceable, polymorphic: true, optional: true

  has_many :items, class_name: "PurchaseOrderItem", dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    draft: "draft",
    confirmed: "confirmed",
    received: "received",
    cancelled: "cancelled"
  }

  def self.generate_next_code(enterprise)
    current_year = Date.current.year
    last_record = enterprise.purchase_orders
      .where("code LIKE ?", "OC-%-#{current_year}")
      .order(created_at: :desc)
      .first
    last_number = last_record&.code&.split("-")&.second.to_i || 0
    "OC-#{(last_number + 1).to_s.rjust(4, '0')}-#{current_year}"
  end

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

  def update_product_stock!
    items.includes(:product).find_each do |item|
      product = item.product
      current_stock = product.stock || 0
      product.update!(stock: current_stock + item.quantity)
    end
  end
end
