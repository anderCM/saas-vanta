class Role < ApplicationRecord
  # Asociations
  has_many :user_enterprise_roles
  has_many :user_enterprises, through: :user_enterprise_roles

  # Validations
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  # Enums
  enum :slug, {
    admin: "admin"
  }
end
