class Admin::SignupRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_super_admin!
  before_action :set_signup_request, only: [ :approve, :reject ]

  def approve
    ActiveRecord::Base.transaction do
      company = Company.create!(
        name: @signup_request.company_name,
        role: @signup_request.role,
        approved: true
      )

      temp_password = SecureRandom.hex(12)
      user = User.create!(
        email: @signup_request.admin_email,
        password: temp_password,
        admin: true,
        company: company
      )

      @signup_request.approved!

      # Envoi du mail
      UserMailer.admin_invitation_email(user, temp_password).deliver_later
    end

    render json: { message: "Entreprise approuvée et email envoyé à l’admin" }, status: :ok
  end


  def reject
    @signup_request.rejected! # méthode fournie par enum
    render json: { message: "Demande rejetée" }, status: :ok
  end

  private

  def set_signup_request
    @signup_request = SignupRequest.find(params[:id])
  end
end
