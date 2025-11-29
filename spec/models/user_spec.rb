require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:first_last_name) }
    it { should validate_presence_of(:second_last_name) }
    it { should validate_presence_of(:email_address) }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should have_secure_password }
  end

  describe 'normalization' do
    it 'normalizes email_address to lowercase and strips whitespace' do
      user = create(:user, email_address: '  TeSt@ExAmPlE.cOm  ')
      expect(user.email_address).to eq('test@example.com')
    end
  end
end
