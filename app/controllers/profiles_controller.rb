class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: current_user.slice(:id, :first_name, :last_name, :email, :phone, :role, :company_id),
      company: {
        id: current_user.company.id,
        name: current_user.company.name
      }
    }
  end

  def update
    current_user.update!(user_params)
  
    if current_user.admin? && params[:company]
      current_user.company.update!(
        params.require(:company).permit(:street, :zipcode, :country)
      )
    end
  
    render json: { user: current_user, company: current_user.company }
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
    params.require(:user).permit(:first_name, :last_name, :email, :phone)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def company_params
    params.require(:company).permit(:street, :zipcode, :country)
  end
end
