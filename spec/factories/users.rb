FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    first_last_name { Faker::Name.last_name }
    second_last_name { Faker::Name.last_name }
    email_address { Faker::Internet.unique.email }
    password { 'password123' }
    phone_number { Faker::PhoneNumber.cell_phone }
    status { 'active' }
    platform_role { 'standard' }
  end
end
