puts "🧹 Suppression des anciennes données..."
UserConnection.destroy_all
PaletteRecord.destroy_all
User.destroy_all
Company.destroy_all


def super_admin
  User.create!(
    email: ENV['ADMIN_EMAIL'],
    password: ENV['ADMIN_PASSWORD'],
    admin: true
  )
  puts("super Admin créé - login 'DEFAULT_ADMIN' / mdp: '123456'")
end

puts "🏢 Création des entreprises..."
roles = [:shipper, :carrier, :recipient]

companies = roles.flat_map do |role|
  3.times.map do |i|
    Company.create!(
      name: "#{role.to_s.capitalize} Company #{i + 1}",
      street: "Street #{i + 1}",
      zipcode: "1000#{i + 1}",
      country: "France"
    ).tap { |c| c.define_singleton_method(:role) { role } }
  end
end

puts "👤 Création des utilisateurs..."
users = companies.flat_map do |company|
  # 1 admin + 1 utilisateur classique
  [
    User.create!(
      email: "admin@#{company.name.parameterize}.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin,
      company: company
    ),
    User.create!(
      email: "user1@#{company.name.parameterize}.com",
      password: "password123",
      password_confirmation: "password123",
      role: company.role,
      company: company
    )
  ]
end

shippers   = users.select { |u| u.role == "shipper" }
carriers   = users.select { |u| u.role == "carrier" }
recipients = users.select { |u| u.role == "recipient" }

puts "🔗 Création des connexions Shipper ↔ Carrier ↔ Recipient..."
connections = []

shippers.each do |shipper|
  carriers.sample(2).each do |carrier|
    recipients.sample(2).each do |recipient|
      connections << UserConnection.create!(
        shipper: shipper,
        carrier: carrier,
        recipient: recipient
      )
    end
  end
end

puts "📦 Génération des PaletteRecords..."
comments = ["RAS", "Livraison rapide", "Problème à l’arrivée", "Chargement partiel"]
generated_transports = Set.new

def unique_transport(existing)
  loop do
    code = "TR-#{rand(1000..9999)}"
    return code unless existing.include?(code)
  end
end

# --- Création aléatoire de palettes pour toutes les connexions ---
connections.each do |conn|
  3.times do |week_index|
    start_of_week = Date.today.beginning_of_year + (week_index * 7).days
    rand(1..3).times do |day_offset|
      loaded   = rand(10..33)
      delivered = loaded
      rendered = rand(0..loaded)
      returned  = rand(0..delivered)
      transport_code = unique_transport(generated_transports)
      generated_transports.add(transport_code)

      PaletteRecord.create!(
        user_id: conn.shipper.id,
        company: conn.shipper.company,
        shipper: conn.shipper,
        carrier: conn.carrier,
        recipient: conn.recipient,
        week: (week_index % 52) + 1,
        date: start_of_week + day_offset.days,
        transport: transport_code,
        loading_point: conn.shipper.company.name,
        delivery_point: conn.recipient.company.name,
        loaded: loaded,
        rendered: rendered,
        delivered: delivered,
        returned: returned,
        due: 0,
        comment: comments.sample
      )
    end
  end
end

# --- Assurer que chaque carrier a plusieurs dettes envers différents shippers et recipients ---
carriers.each do |carrier|
  2.times do
    shipper = shippers.sample
    recipient = recipients.sample
    transport_code = unique_transport(generated_transports)
    generated_transports.add(transport_code)

    loaded = rand(10..25)
    delivered = loaded
    rendered = rand(0..loaded)
    returned = rand(0..delivered)

    PaletteRecord.create!(
      user_id: shipper.id,
      company: shipper.company,
      shipper: shipper,
      carrier: carrier,
      recipient: recipient,
      week: rand(1..52),
      date: Date.today - rand(1..30).days,
      transport: transport_code,
      loading_point: shipper.company.name,
      delivery_point: recipient.company.name,
      loaded: loaded,
      rendered: rendered,
      delivered: delivered,
      returned: returned,
      due: 0,
      comment: "Palette test pour carrier réaliste"
    )
  end
end

puts "🎉 Seeds générées avec succès !"
puts "👉 #{Company.count} companies"
puts "👉 #{User.count} users"
puts "👉 #{UserConnection.count} connexions"
puts "👉 #{PaletteRecord.count} palette records"
