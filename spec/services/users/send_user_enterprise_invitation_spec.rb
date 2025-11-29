require 'rails_helper'

RSpec.describe Users::SendUserEnterpriseInvitation do
  before { ActiveJob::Base.queue_adapter = :test }

  let(:user) { create(:user, status: :pending) }
  let(:enterprise) { create(:enterprise) }
  let(:service) { described_class.new(user: user, enterprise: enterprise) }

  describe '#call' do
    context 'when inputs are valid' do
      it 'returns true' do
        expect(service.call).to be true
      end

      it 'generates an invitation token for the user' do
        expect { service.call }.to change { user.reload.invitation_token }.from(nil)
      end

      it 'enqueues an invitation email' do
        expect { service.call }.to have_enqueued_mail(UserMailer, :invitation_email)
          .with(params: { user: user, enterprise: enterprise }, args: [])
      end

      it 'sets the service as valid' do
        service.call
        expect(service).to be_valid
      end
    end

    context 'when required inputs are missing' do
      it 'returns false when user is missing' do
        service = described_class.new(user: nil, enterprise: enterprise)
        expect(service.call).to be false
        expect(service.errors).to include("User es requerido")
      end

      it 'returns false when enterprise is missing' do
        service = described_class.new(user: user, enterprise: nil)
        expect(service.call).to be false
        expect(service.errors).to include("Enterprise es requerido")
      end
    end

    context 'when an error occurs during execution' do
      before do
        allow(user).to receive(:generate_invitation_token!).and_raise(StandardError.new("Token generation failed"))
      end

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'adds an error message' do
        service.call
        expect(service.errors).to include("Error al enviar invitación: Token generation failed")
      end

      it 'sets the service as invalid' do
        service.call
        expect(service).not_to be_valid
      end
    end
  end
end
