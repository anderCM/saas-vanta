require 'rails_helper'

RSpec.describe CreateNewEnterpriseClient do
  before { ActiveJob::Base.queue_adapter = :test }

  let!(:super_admin_role) { Role.find_or_create_by!(slug: 'super_admin') { |r| r.name = 'Super Admin' } }
  let!(:admin_role) { Role.find_or_create_by!(slug: 'admin') { |r| r.name = 'Admin' } }
  let(:super_admin_user) { create(:user, :super_admin, :active) }

  let(:valid_enterprise_params) do
    ActionController::Parameters.new({
      enterprise_type: 'informal',
      comercial_name: 'Test Company',
      social_reason: 'Test Company SAC',
      address: '123 Test Street',
      email: 'company@test.com',
      phone_number: '999888777',
      users: [
        {
          user_email: 'admin@newcompany.com',
          first_name: 'John',
          first_last_name: 'Doe',
          second_last_name: 'Smith',
          role_slug: 'super_admin'
        }
      ]
    })
  end

  let(:service) { described_class.new(valid_enterprise_params, user_id: super_admin_user.id) }

  describe '#call' do
    context 'when all inputs are valid' do
      it 'returns true' do
        expect(service.call).to be true
      end

      it 'marks the service as valid' do
        service.call
        expect(service.valid?).to be true
      end

      it 'creates a new enterprise' do
        expect { service.call }.to change(Enterprise, :count).by(1)
      end

      it 'creates enterprise with correct attributes' do
        service.call
        enterprise = Enterprise.last
        expect(enterprise.comercial_name).to eq('Test Company')
        expect(enterprise.social_reason).to eq('Test Company SAC')
        expect(enterprise.email).to eq('company@test.com')
      end

      it 'creates a new user for the enterprise' do
        service
        initial_count = User.count
        service.call
        expect(User.count).to eq(initial_count + 1)
      end

      it 'creates user enterprise relationship' do
        expect { service.call }.to change(UserEnterprise, :count).by(1)
      end

      it 'assigns role to user enterprise' do
        expect { service.call }.to change(UserEnterpriseRole, :count).by(1)
      end

      it 'assigns correct role to user' do
        service.call
        user_enterprise = UserEnterprise.last
        expect(user_enterprise.roles).to include(super_admin_role)
      end
    end

    context 'when multiple users are provided' do
      let(:multi_user_params) do
        ActionController::Parameters.new({
          enterprise_type: 'informal',
          comercial_name: 'Multi User Company',
          users: [
            {
              user_email: 'super@company.com',
              first_name: 'Super',
              first_last_name: 'Admin',
              second_last_name: 'User',
              role_slug: 'super_admin'
            },
            {
              user_email: 'admin@company.com',
              first_name: 'Admin',
              first_last_name: 'User',
              second_last_name: 'Test',
              role_slug: 'admin'
            }
          ]
        })
      end

      let(:multi_user_service) { described_class.new(multi_user_params, user_id: super_admin_user.id) }

      it 'creates all users' do
        multi_user_service
        initial_count = User.count
        multi_user_service.call
        expect(User.count).to eq(initial_count + 2)
      end

      it 'creates user enterprise relationships for all users' do
        expect { multi_user_service.call }.to change(UserEnterprise, :count).by(2)
      end

      it 'assigns roles to all users' do
        expect { multi_user_service.call }.to change(UserEnterpriseRole, :count).by(2)
      end
    end

    context 'when no users are provided' do
      let(:no_users_params) do
        ActionController::Parameters.new({
          enterprise_type: 'informal',
          comercial_name: 'No Users Company'
        })
      end

      let(:no_users_service) { described_class.new(no_users_params, user_id: super_admin_user.id) }

      it 'creates enterprise without users' do
        expect { no_users_service.call }.to change(Enterprise, :count).by(1)
        expect(no_users_service.valid?).to be true
      end

      it 'does not create any additional users' do
        no_users_service
        initial_count = User.count
        no_users_service.call
        expect(User.count).to eq(initial_count)
      end
    end

    context 'when enterprise creation fails' do
      let(:invalid_user) { create(:user, :active) }

      let(:invalid_service) { described_class.new(valid_enterprise_params, user_id: invalid_user.id) }

      it 'returns falsy value (from rescue block)' do
        result = invalid_service.call
        expect(result).to be_falsy
      end

      it 'marks the service as invalid' do
        invalid_service.call
        expect(invalid_service.valid?).to be false
      end

      it 'adds error messages' do
        invalid_service.call
        expect(invalid_service.errors).not_to be_empty
      end

      it 'does not create enterprise' do
        expect { invalid_service.call }.not_to change(Enterprise, :count)
      end
    end

    context 'when user invitation fails' do
      let(:invalid_user_params) do
        ActionController::Parameters.new({
          enterprise_type: 'informal',
          comercial_name: 'Test Company',
          users: [
            {
              user_email: 'valid@company.com',
              first_name: 'Valid',
              first_last_name: 'User',
              second_last_name: 'Test',
              role_slug: 'invalid_role'
            }
          ]
        })
      end

      let(:invalid_user_service) { described_class.new(invalid_user_params, user_id: super_admin_user.id) }

      it 'returns falsy value (from rescue block)' do
        result = invalid_user_service.call
        expect(result).to be_falsy
      end

      it 'marks the service as invalid' do
        invalid_user_service.call
        expect(invalid_user_service.valid?).to be false
      end

      it 'rolls back enterprise creation' do
        expect { invalid_user_service.call }.not_to change(Enterprise, :count)
      end

      it 'does not create user due to rollback' do
        invalid_user_service
        initial_count = User.count
        invalid_user_service.call
        expect(User.count).to eq(initial_count)
      end

      it 'adds error message with user details' do
        invalid_user_service.call
        expect(invalid_user_service.errors_message).to include('valid@company.com')
      end
    end

    context 'when second user invitation fails' do
      before do
        create(:user, email_address: 'duplicate@company.com')
        enterprise = create(:enterprise)
        user = User.find_by(email_address: 'duplicate@company.com')
        create(:user_enterprise, user: user, enterprise: enterprise)
      end

      let(:duplicate_user_params) do
        ActionController::Parameters.new({
          enterprise_type: 'informal',
          comercial_name: 'Test Company Duplicate',
          users: [
            {
              user_email: 'first@company.com',
              first_name: 'First',
              first_last_name: 'User',
              second_last_name: 'Test',
              role_slug: 'super_admin'
            },
            {
              user_email: 'duplicate@company.com',
              first_name: 'Duplicate',
              first_last_name: 'User',
              second_last_name: 'Test',
              role_slug: 'admin'
            }
          ]
        })
      end
    end

    context 'transaction rollback behavior' do
      it 'rolls back all changes if any step fails' do
        call_count = 0
        allow_any_instance_of(Users::InviteUserToEnterprise).to receive(:call) do |instance|
          call_count += 1
          if call_count > 1
            instance.instance_variable_set(:@valid, false)
            instance.instance_variable_get(:@errors) << "Simulated failure"
          else
            instance.instance_variable_set(:@valid, true)
          end
        end

        multi_params = ActionController::Parameters.new({
          enterprise_type: 'informal',
          comercial_name: 'Rollback Test',
          users: [
            { user_email: 'user1@test.com', first_name: 'User', first_last_name: 'One', second_last_name: 'Test', role_slug: 'super_admin' },
            { user_email: 'user2@test.com', first_name: 'User', first_last_name: 'Two', second_last_name: 'Test', role_slug: 'admin' }
          ]
        })

        service = described_class.new(multi_params, user_id: super_admin_user.id)

        expect { service.call }.not_to change(Enterprise, :count)
        expect(service.valid?).to be false
      end
    end
  end

  describe '#valid?' do
    it 'returns true after successful call' do
      service.call
      expect(service.valid?).to be true
    end

    it 'returns false after failed call' do
      invalid_params = ActionController::Parameters.new({
        enterprise_type: 'informal',
        comercial_name: 'Test',
        users: [ { user_email: 'test@test.com', first_name: 'Test', first_last_name: 'User', second_last_name: 'Test', role_slug: 'nonexistent_role' } ]
      })
      invalid_service = described_class.new(invalid_params, user_id: super_admin_user.id)

      invalid_service.call
      expect(invalid_service.valid?).to be false
    end
  end

  describe '#errors' do
    it 'returns empty array on success' do
      service.call
      expect(service.errors).to be_empty
    end

    it 'returns array of errors on failure' do
      invalid_params = ActionController::Parameters.new({
        enterprise_type: 'informal',
        comercial_name: 'Test',
        users: [ { user_email: 'test@test.com', first_name: 'Test', first_last_name: 'User', second_last_name: 'Test', role_slug: 'invalid' } ]
      })
      invalid_service = described_class.new(invalid_params, user_id: super_admin_user.id)

      invalid_service.call
      expect(invalid_service.errors).not_to be_empty
    end
  end
end
