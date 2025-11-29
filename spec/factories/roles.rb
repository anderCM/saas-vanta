FactoryBot.define do
  factory :role do
    name { Faker::Job.title }
    slug { 'admin' }
    description { Faker::Lorem.sentence }
  end
end
