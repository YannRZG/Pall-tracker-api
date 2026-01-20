class ApplicationController < ActionController::API
  include ActionController::Cookies

  #before_action :set_current_user
  before_action :authenticate_user!
  before_action :check_company_approved
  #before_action :current_user

  protected

  def set_current_user
    Current.user = User.find_by(id: session[:user_id])
  end
  
  def is_admin?
    user_signed_in? && current_user.admin
  end

  def authenticate_admin!
    if (!is_admin?)
      render json: {
        status: { code: 401,
                  message: "Doit être un utilisateur administrateur." }
      }, status: :unauthorized
    end
  end

  def authenticate_super_admin!
    unless current_user&.super_admin?
      render json: { error: "Accès réservé au super-admin" }, status: :forbidden
    end
  end
  
  def admin_only!
    render json: { error: "Forbidden" }, status: :forbidden unless current_user.role == "admin"
  end

  def check_company_approved
    return if request.path == '/users/sign_out'
    return unless current_user
    return if current_user.super_admin?
    return if current_user.company&.approved?
  
    render json: { error: "Entreprise en attente de validation" }, status: :forbidden
  end

  def authenticate_user!
    Current.user ||= User.find_by(id: session[:user_id])
    render json: { error: "Unauthorized" }, status: :unauthorized unless Current.user
  end

  def current_user
    Current.user
  end
  
end
