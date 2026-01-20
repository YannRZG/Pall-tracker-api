FactoryBot.define do
  factory :palette_record do
    company
    user
    user_connection

    shipper   { user_connection.shipper }
    carrier   { user_connection.carrier }
    recipient { user_connection.recipient }

    week { Date.today.cweek }
    date { Date.today }

    loaded { 20 }
    rendered { 10 }
    delivered { 0 }
    returned { 0 }
  end
end
