FactoryBot.define do
  factory :invitation do
    email { "invite@test.com" }
    token { SecureRandom.hex(20) }
    invited_at { Time.current }
    company
  end
end
