require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    context 'validate_stock' do
      it 'validates that stock is an integer' do
        product = build(:product, stock: 10.5)
        expect(product).not_to be_valid
        expect(product.errors[:base]).to include("El stock debe ser un número entero positivo")
      end

      it 'validates that stock is positive' do
        product = build(:product, stock: -1)
        expect(product).not_to be_valid
        expect(product.errors[:base]).to include("El stock debe ser un número entero positivo")
      end

      it 'allows valid stock' do
        product = build(:product, stock: 10)
        expect(product).to be_valid
      end

      it 'allows nil stock' do
        product = build(:product, stock: nil)
        expect(product).to be_valid
      end
    end

    context 'validate_units_per_package' do
      it 'allows valid units_per_package' do
        product = build(:product, units_per_package: 10)
        expect(product).to be_valid
      end

      it 'allows nil units_per_package' do
        product = build(:product, units_per_package: nil)
        expect(product).to be_valid
      end
    end

    context 'provider_presence_based_on_source' do
      it 'validates that provider is present if source_type is purchased' do
        product = build(:product, source_type: 'purchased', provider: nil)
        expect(product).not_to be_valid
        expect(product.errors[:base]).to include("Proveedor es obligatorio para productos comprados")
      end

      it 'allows valid product with provider if source_type is purchased' do
        product = build(:product, source_type: 'purchased', provider: build(:provider))
        expect(product).to be_valid
      end

      it 'allows nil provider if source_type is not purchased' do
        product = build(:product, source_type: 'manufactured', provider: nil)
        expect(product).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:unit).with_values(
      kg: "kg",
      g: "g",
      lt: "lt",
      ml: "ml",
      un: "un",
      cl: "cl"
    ).backed_by_column_of_type(:string) }

    it { should define_enum_for(:status).with_values(
      active: "active",
      inactive: "inactive",
      discontinued: "discontinued"
    ).backed_by_column_of_type(:string) }
  end
end
