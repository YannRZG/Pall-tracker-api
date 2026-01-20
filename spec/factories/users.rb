FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :shipper }
    company

    trait :admin do
      role { :admin }
    end

    trait :super_admin do
      super_admin { true }
    end

    trait :carrier do
      role { :carrier }
    end

    trait :recipient do
      role { :recipient }
    end
  end
end
