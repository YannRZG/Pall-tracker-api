FactoryBot.define do
  factory :user_connection do
    association :shipper, factory: :user
    association :carrier, factory: :user

    status { :pending }
  end
end
