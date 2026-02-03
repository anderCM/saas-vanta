FactoryBot.define do
  factory :product do
    association :enterprise
    association :provider
    name { Faker::Commerce.product_name }
    buy_price { Faker::Commerce.price(range: 10.0..50.0) }
    sell_cash_price { Faker::Commerce.price(range: 51.0..100.0) }
    sell_credit_price { Faker::Commerce.price(range: 101.0..150.0) }
    unit { Product.units.keys.sample }
    status { Product.statuses.keys.sample }
    source_type { "purchased" }
    stock { Faker::Number.between(from: 1, to: 100) }
    units_per_package { Faker::Number.between(from: 1, to: 50) }
  end
end
