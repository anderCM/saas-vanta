require 'rails_helper'

RSpec.describe Users::InviteUserToEnterprise do
  before { ActiveJob::Base.queue_adapter = :test }

  let(:enterprise) { create(:enterprise) }
  let(:valid_params) do
    {
      enterprise: enterprise,
      user_email: 'newuser@example.com',
      first_name: 'John',
      first_last_name: 'Doe',
      second_last_name: 'Smith'
    }
  end

  let(:service) { described_class.new(**valid_params) }

  describe '#call' do
    context 'when inputs are valid' do
      it 'returns true' do
        expect(service.call).to be true
      end

      it 'creates a new user with pending status' do
        expect { service.call }.to change(User, :count).by(1)
        user = User.last
        expect(user.email_address).to eq('newuser@example.com')
        expect(user.status).to eq('pending')
        expect(user.platform_role).to eq('standard')
      end

      it 'creates a user enterprise relationship' do
        expect { service.call }.to change(UserEnterprise, :count).by(1)
        user = User.last
        expect(UserEnterprise.last.user).to eq(user)
        expect(UserEnterprise.last.enterprise).to eq(enterprise)
      end

      it 'calls SendUserEnterpriseInvitation service' do
        invitation_service = instance_double(Users::SendUserEnterpriseInvitation, call: true, errors: [], valid?: true)
        allow(Users::SendUserEnterpriseInvitation).to receive(:new).and_return(invitation_service)

        service.call

        expect(Users::SendUserEnterpriseInvitation).to have_received(:new).with(user: kind_of(User), enterprise: enterprise)
        expect(invitation_service).to have_received(:call)
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, email_address: 'newuser@example.com') }

      it 'does not create a new user' do
        expect { service.call }.not_to change(User, :count)
      end

      it 'creates a user enterprise relationship for existing user' do
        expect { service.call }.to change(UserEnterprise, :count).by(1)
        expect(UserEnterprise.last.user).to eq(existing_user)
      end
    end

    context 'when user is already in the enterprise' do
      let!(:existing_user) { create(:user, email_address: 'newuser@example.com') }

      before do
        create(:user_enterprise, user: existing_user, enterprise: enterprise)
      end

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'adds an error message' do
        service.call
        expect(service.errors).to include("Error al invitar usuario: User already exists in this enterprise")
      end
    end

    context 'when SendUserEnterpriseInvitation fails' do
      before do
        invitation_service = instance_double(Users::SendUserEnterpriseInvitation, call: false, errors: [ "Some error" ], valid?: false)
        allow(Users::SendUserEnterpriseInvitation).to receive(:new).and_return(invitation_service)
      end

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'adds errors from the invitation service' do
        service.call
        expect(service.errors_message).to include("Some error")
      end
    end

    context 'when required inputs are missing' do
      it 'returns false when enterprise is missing' do
        invalid_params = valid_params.merge(enterprise: nil)
        service = described_class.new(**invalid_params)

        expect(service.call).to be false
        expect(service.errors).to include("Enterprise es requerido")
      end

      it 'returns false when email is missing' do
        invalid_params = valid_params.merge(user_email: nil)
        service = described_class.new(**invalid_params)

        expect(service.call).to be false
        expect(service.errors).to include("User_email es requerido")
      end
    end
  end
end
