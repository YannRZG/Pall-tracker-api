class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :ensure_company_access

  # GET /companies/:id/dashboard
  def dashboard
    # Récupération des palettes selon le rôle
    records = case current_user.role
    when "shipper"
                PaletteRecord.where(shipper: current_user)
    when "carrier"
                PaletteRecord.where(carrier: current_user)
    when "recipient"
                PaletteRecord.where(recipient: current_user)
    when "admin"
                PaletteRecord.where(company: @company)
    else
                PaletteRecord.none
    end

    # Filtrage par company si ce n'est pas un super admin
    records = records.where(company: @company) unless current_user.super_admin?

    # Préchargement des associations
    records = records.includes(:shipper, :carrier, :recipient).order(week: :desc)

    # Calcul des stats
    stats = {
      loading_debt: records.sum(&:loading_debt),
      delivery_debt: records.sum(&:delivery_debt),
      total_debt: records.sum { |r| r.loading_debt.to_f + r.delivery_debt.to_f },
      transports_count: records.count
    }

    # Récupération des utilisateurs de la company
    users = @company.users.select(:id, :email, :role)

    # Réponse JSON complète
    render json: {
      company: { id: @company.id, name: @company.name, role: @company.role&.name },
      stats: stats,
      users: users,              # <-- ici les users
      records: records.as_json(
        methods: [ :loading_debt, :delivery_debt ],
        only: [ :id, :date, :transport, :loading_point, :delivery_point ]
      )
    }
  rescue => e
    render json: { error: e.message }, status: 500
  end


  private

  def set_company
    @company = Company.find(params[:id])
  end

  def ensure_company_access
    return if current_user.super_admin?
    return if current_user.company_id == @company.id

    render json: { error: "Accès interdit à cette entreprise" }, status: :forbidden
  end
end
