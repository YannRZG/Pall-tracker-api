class ApplicationController < ActionController::API

  protected
  
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
  
end
