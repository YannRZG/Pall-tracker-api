puts "🧹 Suppression des anciennes données..."
PaletteRecord.destroy_all
UserConnection.destroy_all
User.destroy_all
Role.destroy_all
Company.destroy_all

# ============================================================
# ROLES
# ============================================================
puts "🎭 Création des rôles..."
roles = [
  { name: "Shipper",   code: "shipper" },
  { name: "Carrier",   code: "carrier" },
  { name: "Recipient", code: "recipient" }
].map { |attrs| Role.create!(attrs) }
puts "✅ #{roles.count} rôles créés"

# ============================================================
# SUPER ADMIN
# ============================================================
puts "👑 Création du super-admin..."
User.create!(
  email: ENV['ADMIN_EMAIL'] || "superadmin@example.com",
  password: ENV['ADMIN_PASSWORD'] || "password123",
  password_confirmation: ENV['ADMIN_PASSWORD'] || "password123",
  first_name: "Super",
  last_name: "Admin",
  super_admin: true,
  admin: false,
  company: nil
)
puts "✅ Super-admin créé"

# ============================================================
# COMPANIES APPROUVÉES
# ============================================================
puts "🏢 Création des entreprises APPROUVÉES..."
companies = 6.times.map do |i|
  Company.create!(
    name: "Company #{i + 1}",
    street: "Street #{i + 1}",
    zipcode: "1000#{i}",
    country: "France",
    role: roles.sample,
    approved: true
  )
end
puts "✅ #{companies.count} entreprises créées"

# ============================================================
# COMPANIES EN ATTENTE
# ============================================================
puts "⏳ Création des entreprises EN ATTENTE..."
5.times do |i|
  Company.create!(
    name: "Pending Company #{i + 1}",
    street: "Pending Street #{i + 1}",
    zipcode: "9000#{i}",
    country: "France",
    role: roles.sample,
    approved: false
  )
end

# ============================================================
# USERS (1 ADMIN + 1 USER PAR COMPANY)
# ============================================================
puts "👤 Création des utilisateurs..."
companies.each do |company|
  User.create!(
    email: "admin@#{company.name.parameterize}.com",
    password: "password123",
    password_confirmation: "password123",
    admin: true,
    company: company
  )

  User.create!(
    email: "user@#{company.name.parameterize}.com",
    password: "password123",
    password_confirmation: "password123",
    admin: false,
    company: company
  )
end

# ============================================================
# USER CONNECTIONS (COMPANY ↔ COMPANY)
# ============================================================
puts "🔗 Création des demandes de connexion..."
connections = []

companies.combination(2).each do |requester_company, receiver_company|
  # chaque connexion doit avoir un rôle spécifié pour le receiver
  role_for_receiver = roles.sample
  connections << UserConnection.create!(
    requester: requester_company,
    receiver: receiver_company,
    role: role_for_receiver,
    status: :accepted
  )
end

puts "✅ #{connections.count} connexions créées"

# ============================================================
# PALETTE RECORDS (LIÉES AUX CONNEXIONS)
# ============================================================
puts "📦 Création des PaletteRecords..."
comments = ["RAS", "Livraison OK", "Problème signalé"]
transport_codes = Set.new

def unique_transport(existing)
  loop do
    code = "TR-#{rand(1000..9999)}"
    return code unless existing.include?(code)
  end
end

connections.each do |connection|
  # On prend un user aléatoire de chaque company pour représenter le rôle
  shipper_user   = connection.requester.users.sample
  carrier_user   = connection.receiver.users.sample
  recipient_user = connection.receiver.users.sample

  3.times do
    code = unique_transport(transport_codes)
    transport_codes << code

    PaletteRecord.create!(
      user: shipper_user,
      user_connection: connection,
      company: connection.requester, # la company qui "possède" la palette

      shipper: shipper_user,
      carrier: carrier_user,
      recipient: recipient_user,

      week: rand(1..52),
      date: Date.today - rand(1..30).days,
      transport: code,
      loading_point: connection.requester.name,
      delivery_point: connection.receiver.name,
      loaded: rand(10..30),
      delivered: rand(10..30),
      rendered: rand(0..10),
      returned: rand(0..5),
      due: 0,
      comment: comments.sample
    )
  end
end


puts "🎉 Seeds générées avec succès !"
puts "👉 Companies : #{Company.count}"
puts "👉 Users : #{User.count}"
puts "👉 Roles : #{Role.count}"
puts "👉 Connections : #{UserConnection.count}"
puts "👉 Palettes : #{PaletteRecord.count}"
