require 'rails_helper'

RSpec.describe Products::CreateProducts do
  let(:enterprise) { create(:enterprise) }
  let(:provider) { create(:provider, enterprise: enterprise) }
  let(:valid_attributes) do
    [
      {
        name: Faker::Commerce.product_name,
        buy_price: Faker::Commerce.price(range: 10.0..50.0),
        sell_cash_price: Faker::Commerce.price(range: 51.0..100.0),
        sell_credit_price: Faker::Commerce.price(range: 101.0..150.0),
        stock: Faker::Number.between(from: 10, to: 100),
        units_per_package: Faker::Number.between(from: 1, to: 10),
        unit: 'un',
        status: 'active',
        source_type: 'purchased',
        provider_id: provider.id
      },
      {
        name: Faker::Commerce.product_name,
        buy_price: Faker::Commerce.price(range: 10.0..50.0),
        sell_cash_price: Faker::Commerce.price(range: 51.0..100.0),
        sell_credit_price: Faker::Commerce.price(range: 101.0..150.0),
        stock: Faker::Number.between(from: 10, to: 100),
        units_per_package: Faker::Number.between(from: 1, to: 10),
        unit: 'kg',
        status: 'active',
        source_type: 'manufactured'
      }
    ]
  end

  subject { described_class.new(products: products_input, enterprise: enterprise) }

  describe '#call' do
    context 'when all products are valid' do
      let(:products_input) { valid_attributes }

      it 'creates all products' do
        expect { subject.call }.to change(Product, :count).by(2)
      end

      it 'sets the service as valid' do
        subject.call
        expect(subject).to be_valid
      end

      it 'has no errors' do
        subject.call
        expect(subject.errors).to be_empty
      end
    end

    context 'when some products are invalid' do
      let(:invalid_product_attributes) do
        {
          name: "Invalid Product",
          buy_price: Faker::Commerce.price(range: 10.0..50.0),
          sell_cash_price: Faker::Commerce.price(range: 51.0..100.0),
          sell_credit_price: Faker::Commerce.price(range: 101.0..150.0),
          source_type: 'purchased',
          provider_id: nil
        }
      end

      let(:products_input) { valid_attributes + [ invalid_product_attributes ] }

      it 'creates only the valid products' do
        expect { subject.call }.to change(Product, :count).by(2)
      end

      it 'sets the service as invalid' do
        subject.call
        expect(subject).not_to be_valid
      end

      it 'collects errors for the invalid product' do
        subject.call
        expect(subject.errors).not_to be_empty

        error_entry = subject.errors.find { |e| e[:name] == "Invalid Product" }
        expect(error_entry).to be_present
        expect(error_entry[:errors]).to include("Proveedor es obligatorio para productos comprados")
      end
    end

    context 'when all products are invalid' do
      let(:products_input) do
        [
          {
            name: "Invalid 1",
            source_type: 'purchased',
            provider_id: nil
          },
          {
            name: "Invalid 2",
            source_type: 'purchased',
            provider_id: nil
          }
        ]
      end

      it 'creates no products' do
        expect { subject.call }.not_to change(Product, :count)
      end

      it 'sets the service as invalid' do
        subject.call
        expect(subject).not_to be_valid
      end

      it 'collects errors for all products' do
        subject.call
        expect(subject.errors.size).to eq(2)
      end
    end

    context 'edge cases' do
      context 'with empty product list' do
        let(:products_input) { [] }

        it 'is valid' do
          subject.call
          expect(subject).to be_valid
        end

        it 'creates no products' do
          expect { subject.call }.not_to change(Product, :count)
        end
      end
    end
  end
end
