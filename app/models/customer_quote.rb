class CustomerQuote < ApplicationRecord
  include Documentable

  belongs_to :customer
  belongs_to :seller, class_name: "User"

  has_many :items, class_name: "CustomerQuoteItem", dependent: :destroy
  has_many :sales, as: :sourceable
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected",
    expired: "expired"
  }

  def self.generate_next_code(enterprise)
    current_year = Date.current.year
    last_record = enterprise.customer_quotes
      .where("code LIKE ?", "COT-%-#{current_year}")
      .order(created_at: :desc)
      .first
    last_number = last_record&.code&.split("-")&.second.to_i || 0
    "COT-#{(last_number + 1).to_s.rjust(4, '0')}-#{current_year}"
  end

  # Instance methods
  def can_edit?
    pending?
  end

  def can_accept?
    pending? && items.any?
  end

  def can_reject?
    pending?
  end

  def can_expire?
    pending?
  end

  def accept!
    return false unless can_accept?

    transaction do
      update!(status: :accepted)
      create_sale_from_quote!
    end
  end

  def reject!
    return false unless can_reject?

    update!(status: :rejected)
  end

  def expire!
    return false unless can_expire?

    update!(status: :expired)
  end

  def status_badge_class
    case status
    when "pending" then "badge-secondary"
    when "accepted" then "badge-success"
    when "rejected" then "badge-destructive"
    when "expired" then "badge-info"
    else "badge-secondary"
    end
  end

  def status_label
    {
      "pending" => "Pendiente",
      "accepted" => "Aceptada",
      "rejected" => "Rechazada",
      "expired" => "Expirada"
    }[status] || status.humanize
  end

  private

  def create_sale_from_quote!
    sale = enterprise.sales.create!(
      code: Sale.generate_next_code(enterprise),
      customer: customer,
      seller: seller,
      created_by: created_by,
      destination: destination,
      issue_date: Date.current,
      status: :pending,
      notes: notes,
      sourceable: self
    )

    items.each do |item|
      sale.items.create!(
        product: item.product,
        quantity: item.quantity,
        unit_price: item.unit_price
      )
    end

    sale.save!
  end
end
