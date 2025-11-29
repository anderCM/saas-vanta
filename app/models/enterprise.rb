class Enterprise < ApplicationRecord
    # Asociations
    has_many :user_enterprises
    has_many :users, through: :user_enterprises

    # Validations
    validates :tax_id, :social_reason, :comercial_name, :address, :email, :subdomain, presence: true
    validates :tax_id, :subdomain, :email, uniqueness: true

    # Enums
    enum :status, {
        activating: "activating",
        active: "active",
        inactive: "inactive"
    }
end
