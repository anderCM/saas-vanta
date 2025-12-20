require 'rails_helper'

RSpec.describe Enterprise, type: :model do
  subject { create(:enterprise) }

  describe 'validations' do
    it { should validate_presence_of(:comercial_name) }

    it { should allow_value('test@example.com').for(:email) }
    it { should allow_value(nil).for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe 'tax_id validation' do
    it 'is valid when starts with 10 and has 11 digits' do
      enterprise = build(:enterprise, tax_id: '10456789123')
      expect(enterprise).to be_valid
    end

    it 'is valid when starts with 20 and has 11 digits' do
      enterprise = build(:enterprise, tax_id: '20456789123')
      expect(enterprise).to be_valid
    end

    it 'is invalid with incorrect format' do
      enterprise = build(:enterprise, tax_id: '30456789123')
      expect(enterprise).not_to be_valid
      expect(enterprise.errors[:base]).to include(
        "El RUC debe ser un número válido de 11 dígitos (empezar con 10 o 20)"
      )
    end
  end

  describe 'enterprise_type callback' do
    it 'sets enterprise_type to formal when tax_id is present' do
      enterprise = create(:enterprise, tax_id: '20456789123')
      expect(enterprise.enterprise_type).to eq('formal')
    end

    it 'sets enterprise_type to informal when tax_id is nil' do
      enterprise = create(:enterprise, tax_id: nil)
      expect(enterprise.enterprise_type).to eq('informal')
    end
  end

  describe 'subdomain generation' do
    it 'generates subdomain from comercial_name' do
      enterprise = create(:enterprise, comercial_name: 'Mi Empresa SAC')
      expect(enterprise.subdomain).to eq('mi-empresa-sac')
    end

    it 'adds error if subdomain already exists' do
      create(:enterprise, comercial_name: 'Empresa Duplicada')

      enterprise = build(:enterprise, comercial_name: 'Empresa Duplicada')
      expect(enterprise).not_to be_valid
      expect(enterprise.errors[:base]).to include(
        "Parece que la empresa ya existe, si crees que se trata de un error, por favor comunícate con el soporte"
      )
    end
  end

  describe 'phone number validation' do
    it 'accepts local cellphone format' do
      enterprise = build(:enterprise, phone_number: '987654321')
      expect(enterprise).to be_valid
    end

    it 'accepts international format with +' do
      enterprise = build(:enterprise, phone_number: '+51987654321')
      expect(enterprise).to be_valid
    end

    it 'rejects invalid phone number' do
      enterprise = build(:enterprise, phone_number: '12345')
      expect(enterprise).not_to be_valid
      expect(enterprise.errors[:base]).to include(
        "El Número de teléfono debe tener cualquiera de los siguientes formatos: 987654321, +51987654321, 51987654321"
      )
    end
  end
end
