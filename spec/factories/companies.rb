FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    approved { true }
  end
end
