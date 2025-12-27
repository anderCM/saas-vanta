FactoryBot.define do
  factory :provider do
    association :enterprise
    name { Faker::Company.name }
    email { Faker::Internet.email }
  end
end
