class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    invitation = Invitation.find_by(token: params[:token])
  
    return render json: { error: "Invitation not found" }, status: :not_found unless invitation
  
    render json: {
      invitation: {
        email: invitation.email,
        company_id: invitation.company_id,
        company_name: invitation.company.name
      }
    }
  end  
  
end
