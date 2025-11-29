class UserEnterpriseRole < ApplicationRecord
  belongs_to :user_enterprise
  belongs_to :role
end
