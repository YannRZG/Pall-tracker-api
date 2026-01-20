# app/controllers/admin/companies_controller.rb
class Admin::CompaniesController < ApplicationController
  before_action :set_signup_request, only: [ :approve ]

  # GET /admin/companies
  def index
    companies = Company.order(created_at: :desc)
    render json: companies
  end

  # POST /admin/signup_requests/:id/approve
  def approve
    ActiveRecord::Base.transaction do
      # Vérifie que le rôle demandé existe
      role = Role.find_by(code: @signup_request.role)
      unless role
        render json: { error: "Role '#{@signup_request.role}' invalide" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # Création de l'entreprise
      company = Company.create!(
        name: @signup_request.company_name,
        approved: true
      )

      # Création de l'admin user
      User.create!(
        email: @signup_request.admin_email,
        password: SecureRandom.hex(12),
        admin: true,
        company: company,
        role: role
      )

      # Met à jour le statut de la demande
      @signup_request.update!(status: :approved)
    end

    render json: { message: "Entreprise approuvée avec succès ✅" }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  # DELETE /admin/companies/:id
  def destroy
    company = Company.find(params[:id])
    company.destroy
    render json: { success: true }
  end

  private

  def set_signup_request
    @signup_request = SignupRequest.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "SignupRequest introuvable" }, status: :not_found
  end
end
