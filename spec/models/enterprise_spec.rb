require 'rails_helper'

RSpec.describe Enterprise, type: :model do
  subject { create(:enterprise) }

  describe 'validations' do
    it { should validate_presence_of(:tax_id) }
    it { should validate_presence_of(:social_reason) }
    it { should validate_presence_of(:comercial_name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subdomain) }

    it { should validate_uniqueness_of(:tax_id) }
    it { should validate_uniqueness_of(:subdomain) }
    it { should validate_uniqueness_of(:email) }
  end
end
