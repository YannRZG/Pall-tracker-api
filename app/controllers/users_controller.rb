class UsersController < ApplicationController


  def index
    @users = User.all
  end
  
  def check_admin
    render json: {
      admin: current_user&.admin?,
      super_admin: current_user&.super_admin?
    }
  end
  

  def signup_from_invite
    invitation = Invitation.find_by(token: params[:token])
    return render json: { error: "Invitation invalide" }, status: :unprocessable_entity unless invitation
  
    user = User.new(
      email: invitation.email,
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      company: invitation.company
    )
  
    if user.save
      invitation.destroy
  
      token = JwtService.encode(user_id: user.id)
  
      render json: {
        token: token,
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          company_id: user.company_id
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  
  private
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone, :password, :password_confirmation)
  end
  

end