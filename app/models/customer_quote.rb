class CustomerQuote < ApplicationRecord
  # Associations
  belongs_to :enterprise
  belongs_to :customer
  belongs_to :created_by, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :destination, class_name: "Ubigeo", optional: true

  has_many :items, class_name: "CustomerQuoteItem", dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :code, presence: true, uniqueness: { scope: :enterprise_id }
  validates :issue_date, presence: true
  validates :status, presence: true

  # Enums
  enum :status, {
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected",
    expired: "expired"
  }

  # Callbacks
  before_save :calculate_totals

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

    update!(status: :accepted)
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

  def calculate_totals
    self.total = items.sum { |item| item.total || 0 }
    self.subtotal = PeruTax.base_amount(total)
    self.tax = PeruTax.extract_igv(total)
  end
end
