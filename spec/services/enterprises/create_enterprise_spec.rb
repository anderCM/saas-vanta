require 'rails_helper'

RSpec.describe Enterprises::CreateEnterprise do
  let(:super_admin_user) { create(:user, status: 'active', platform_role: 'super_admin') }
  let(:standard_user) { create(:user, status: 'active', platform_role: 'standard') }
  let(:inactive_user) { create(:user, status: 'inactive', platform_role: 'super_admin') }

  let(:valid_params) do
    {
      comercial_name: 'Mi Empresa Test',
      social_reason: 'Mi Empresa SAC',
      email: 'empresa@test.com',
      phone_number: 912345678,
      address: 'Av. Principal 123'
    }
  end

  describe '#call' do
    context 'when user is a super_admin and active' do
      let(:service) { described_class.new(user_id: super_admin_user.id, **valid_params) }

      it 'creates a new enterprise successfully' do
        expect { service.call }.to change(Enterprise, :count).by(1)
      end

      it 'returns valid service' do
        service.call
        expect(service).to be_valid
      end

      it 'sets the enterprise status to active' do
        service.call
        expect(service.enterprise.status).to eq('active')
      end

      it 'stores the enterprise in the service attribute' do
        service.call
        expect(service.enterprise).to be_a(Enterprise)
        expect(service.enterprise.comercial_name).to eq('Mi Empresa Test')
      end

      it 'sets enterprise_type based on tax_id presence' do
        service.call
        expect(service.enterprise.enterprise_type).to eq('informal')
      end

      context 'when tax_id is provided' do
        let(:params_with_tax_id) { valid_params.merge(tax_id: 20123456789) }
        let(:service_with_tax_id) { described_class.new(user_id: super_admin_user.id, **params_with_tax_id) }

        it 'sets enterprise_type to formal' do
          service_with_tax_id.call
          expect(service_with_tax_id.enterprise.enterprise_type).to eq('formal')
        end
      end
    end

    context 'when user is not a super_admin' do
      let(:service) { described_class.new(user_id: standard_user.id, **valid_params) }

      it 'does not create an enterprise' do
        expect { service.call }.not_to change(Enterprise, :count)
      end

      it 'returns invalid service' do
        service.call
        expect(service).not_to be_valid
      end

      it 'adds an error message about permissions' do
        service.call
        expect(service.errors_message).to include('El usuario no tiene los permisos necesarios')
      end
    end

    context 'when user is inactive' do
      let(:service) { described_class.new(user_id: inactive_user.id, **valid_params) }

      it 'does not create an enterprise' do
        expect { service.call }.not_to change(Enterprise, :count)
      end

      it 'returns invalid service' do
        service.call
        expect(service).not_to be_valid
      end

      it 'adds an error message about user not being active' do
        service.call
        expect(service.errors_message).to include('El usuario no se encuentra activo')
      end
    end

    context 'when user does not exist' do
      let(:service) { described_class.new(user_id: -1, **valid_params) }

      it 'does not create an enterprise' do
        expect { service.call }.not_to change(Enterprise, :count)
      end

      it 'returns invalid service' do
        service.call
        expect(service).not_to be_valid
      end

      it 'adds an error message' do
        service.call
        expect(service.errors_message).to include('Error al crear la empresa')
      end
    end

    context 'when enterprise validation fails' do
      let(:invalid_enterprise_params) { { comercial_name: nil } }
      let(:service) { described_class.new(user_id: super_admin_user.id, **invalid_enterprise_params) }

      it 'does not create an enterprise' do
        expect { service.call }.not_to change(Enterprise, :count)
      end

      it 'returns invalid service' do
        service.call
        expect(service).not_to be_valid
      end

      it 'adds an error message' do
        service.call
        expect(service.errors_message).to include('Error al crear la empresa')
      end
    end

    context 'when enterprise with same comercial_name already exists' do
      before do
        create(:enterprise, comercial_name: 'Mi Empresa Test')
      end

      let(:service) { described_class.new(user_id: super_admin_user.id, **valid_params) }

      it 'does not create a duplicate enterprise' do
        expect { service.call }.not_to change(Enterprise, :count)
      end

      it 'returns invalid service due to subdomain conflict' do
        service.call
        expect(service).not_to be_valid
      end
    end
  end

  describe '#enterprise' do
    let(:service) { described_class.new(user_id: super_admin_user.id, **valid_params) }

    context 'before calling the service' do
      it 'returns nil' do
        expect(service.enterprise).to be_nil
      end
    end

    context 'after successfully calling the service' do
      before { service.call }

      it 'returns the created enterprise' do
        expect(service.enterprise).to be_persisted
      end
    end
  end
end
