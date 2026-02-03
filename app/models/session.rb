class Session < ApplicationRecord
  belongs_to :user
  belongs_to :enterprise, optional: true
end
