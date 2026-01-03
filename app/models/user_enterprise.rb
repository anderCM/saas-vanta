class UserEnterprise < ApplicationRecord
  # Asociations
  belongs_to :user
  belongs_to :enterprise
  has_many :user_enterprise_roles, dependent: :destroy
  has_many :roles, through: :user_enterprise_roles
end
