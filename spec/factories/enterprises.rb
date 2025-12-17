FactoryBot.define do
  factory :enterprise do
    tax_id { "20#{Faker::Number.unique.number(digits: 9)}".to_i }
    social_reason { Faker::Company.name }
    comercial_name { Faker::Company.name }
    address { Faker::Address.full_address }
    email { Faker::Internet.unique.email }
    phone_number { "9#{Faker::Number.unique.number(digits: 8)}".to_i }
    status { 'active' }
  end
end
