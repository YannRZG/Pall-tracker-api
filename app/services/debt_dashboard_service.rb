class DebtDashboardService
  def initialize(user)
    @user = user
  end

  def call
    role_code = @user.company.role&.code

    case role_code
    when "shipper"
      debt_for_shipper
    when "carrier"
      debt_for_carrier
    when "recipient"
      debt_for_recipient
    when "admin"
      debt_for_admin
    else
      { owed_by_me: [], owed_to_me: [] }
    end
  end

  private

  # ----------------------
  # Admin → voir toutes les dettes de la company
  # ----------------------
  def debt_for_admin
    records = PaletteRecord.where(company: @user.company)
                           .includes(:shipper, :carrier, :recipient)

    # Regrouper par company des autres utilisateurs
    owed_by_me = {} # Ce que l’entreprise doit
    owed_to_me = {} # Ce qui est dû à l’entreprise

    # Pour chaque record, calculer les dettes
    records.each do |r|
      # Shipper → Carrier
      if r.shipper && r.carrier
        owed_to_me[r.carrier.company] ||= []
        owed_to_me[r.carrier.company] << r
      end

      # Carrier → Recipient
      if r.carrier && r.recipient
        owed_to_me[r.recipient.company] ||= []
        owed_to_me[r.recipient.company] << r
      end
    end

    # Transformer les hashes en tableaux comme pour les autres rôles
    owed_by_me_array = [] # Tu peux le calculer si tu veux les dettes que l'entreprise doit
    owed_to_me_array = owed_to_me.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    { owed_by_me: owed_by_me_array, owed_to_me: owed_to_me_array }
  end

  # ----------------------
  # Shipper → dettes par Carrier
  # ----------------------
  def debt_for_shipper
    records = PaletteRecord.for_shipper(@user).includes(carrier: :company)

    # Supprimer les records sans carrier ou sans company
    records = records.select { |r| r.carrier&.company }

    companies = records.group_by { |r| r.carrier.company }.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    { owed_by_me: [], owed_to_me: companies }
  end

  # ----------------------
  # Carrier → dettes aux shippers / dettes des recipients
  # ----------------------
  def debt_for_carrier
    # Ce que le carrier doit → dettes aux shippers
    owed_by_me_records = PaletteRecord.for_carrier(@user).includes(shipper: :company)
    owed_by_me_records = owed_by_me_records.select { |r| r.shipper&.company }
    owed_by_me = owed_by_me_records.group_by { |r| r.shipper.company }.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    # Ce qui lui est dû → dettes des recipients
    owed_to_me_records = PaletteRecord.for_carrier(@user).includes(recipient: :company)
    owed_to_me_records = owed_to_me_records.select { |r| r.recipient&.company }
    owed_to_me = owed_to_me_records.group_by { |r| r.recipient.company }.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    { owed_by_me: owed_by_me, owed_to_me: owed_to_me }
  end

  # ----------------------
  # Recipient → dettes aux shippers / dettes des carriers
  # ----------------------
  def debt_for_recipient
    # Ce que le recipient doit → dettes aux shippers
    owed_by_me_records = PaletteRecord.for_recipient(@user).includes(shipper: :company)
    owed_by_me_records = owed_by_me_records.select { |r| r.shipper&.company }
    owed_by_me = owed_by_me_records.group_by { |r| r.shipper.company }.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    # Ce qui lui est dû → dettes des carriers
    owed_to_me_records = PaletteRecord.for_recipient(@user).includes(carrier: :company)
    owed_to_me_records = owed_to_me_records.select { |r| r.carrier&.company }
    owed_to_me = owed_to_me_records.group_by { |r| r.carrier.company }.map do |company, recs|
      {
        id: company.id,
        name: company.name,
        loading_debt: recs.sum(&:loading_debt),
        delivery_debt: recs.sum(&:delivery_debt),
        total_debt: recs.sum { |r| r.loading_debt + r.delivery_debt },
        transports_count: recs.count
      }
    end

    { owed_by_me: owed_by_me, owed_to_me: owed_to_me }
  end
end
