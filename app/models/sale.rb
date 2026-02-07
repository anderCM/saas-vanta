class Sale < ApplicationRecord
  include Documentable

  belongs_to :customer
  belongs_to :seller, class_name: "User"
  belongs_to :sourceable, polymorphic: true, optional: true

  has_many :items, class_name: "SaleItem", dependent: :destroy
  has_many :purchase_orders, as: :sourceable
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  enum :status, { pending: "pending", confirmed: "confirmed", cancelled: "cancelled" }

  def self.generate_next_code(enterprise)
    current_year = Date.current.year
    last_record = enterprise.sales
      .where("code LIKE ?", "VTA-%-#{current_year}")
      .order(created_at: :desc)
      .first
    last_number = last_record&.code&.split("-")&.second.to_i || 0
    "VTA-#{(last_number + 1).to_s.rjust(4, '0')}-#{current_year}"
  end

  def can_edit?
    pending?
  end

  def can_confirm?
    pending? && items.any?
  end

  def can_cancel?
    pending?
  end

  def can_generate_purchase_orders?
    confirmed? && purchase_orders.empty? && enterprise.settings&.dropshipping_enabled?
  end

  def confirm!
    return false unless can_confirm?

    transaction do
      update!(status: :confirmed)
      update_product_stock!
    end
  end

  def cancel!
    return false unless can_cancel?

    update!(status: :cancelled)
  end

  def status_badge_class
    case status
    when "pending" then "badge-secondary"
    when "confirmed" then "badge-success"
    when "cancelled" then "badge-destructive"
    else "badge-secondary"
    end
  end

  def status_label
    { "pending" => "Pendiente", "confirmed" => "Confirmada", "cancelled" => "Cancelada" }[status] || status.humanize
  end

  def generate_purchase_orders!(created_by:)
    return false unless can_generate_purchase_orders?

    items_by_provider = items.includes(product: :provider).group_by { |item| item.product.provider }

    transaction do
      items_by_provider.each do |provider, sale_items|
        next if provider.nil?

        po = enterprise.purchase_orders.create!(
          code: PurchaseOrder.generate_next_code(enterprise),
          provider: provider,
          sourceable: self,
          delivery_address: customer.ubigeo&.full_path,
          issue_date: Date.current,
          status: :draft,
          created_by: created_by,
          notes: "OC generada desde venta #{code} - Cliente: #{customer.name}"
        )

        sale_items.each do |item|
          po.items.create!(
            product: item.product,
            quantity: item.quantity,
            unit_price: item.product.buy_price
          )
        end

        po.save!
      end
    end
  end

  private

  def update_product_stock!
    items.includes(:product).find_each do |item|
      product = item.product
      current_stock = product.stock || 0
      new_stock = current_stock - item.quantity
      product.update!(stock: [new_stock, 0].max)
    end
  end
end
