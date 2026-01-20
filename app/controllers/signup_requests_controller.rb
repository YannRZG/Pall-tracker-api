class SignupRequestsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    signup_request = SignupRequest.new(signup_request_params)

    if signup_request.save
      render json: { message: "Demande envoyée avec succès ✅" }, status: :created
    else
      render json: { errors: signup_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def signup_request_params
    params.require(:signup_request).permit(:company_name, :admin_email, :role_id, :message)
  end
end
