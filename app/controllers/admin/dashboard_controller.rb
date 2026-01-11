class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_super_admin

  def index
    companies = Company.includes(:users)

    render json: {
      stats: {
        companies_count: Company.count,
        users_count: User.count,
        palette_records_count: PaletteRecord.count
      },
      companies: companies.map do |c|
        {
          id: c.id,
          name: c.name,
          users: c.users.select(:id, :email, :role)
        }
      end
    }
  end

  private

  def ensure_super_admin
    render json: { error: "Accès refusé" }, status: :forbidden unless current_user.super_admin?
  end
end
