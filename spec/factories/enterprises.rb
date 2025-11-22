FactoryBot.define do
  factory :enterprise do
    tax_id { Faker::Number.unique.number(digits: 11) }
    social_reason { Faker::Company.name }
    comercial_name { Faker::Company.name }
    address { Faker::Address.full_address }
    email { Faker::Internet.unique.email }
    subdomain { Faker::Internet.unique.domain_word }
    phone_number { Faker::PhoneNumber.cell_phone }
    status { 'active' }
  end
end
