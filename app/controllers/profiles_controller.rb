class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: current_user.slice(:id, :first_name, :last_name, :email, :role, :company_id),
      company: {
        id: current_user.company.id,
        name: current_user.company.name
      }
    }
  end

  def update
    if current_user.update(profile_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_password
    if current_user.update(password_params)
      render json: { success: true }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
