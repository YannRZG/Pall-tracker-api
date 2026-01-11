class InvitationsController < ApplicationController
  # GET /invitations/accept/:token

  def show
    invitation = Invitation.includes(:company).find_by(token: params[:token])

    return render json: { error: 'Invitation invalide' }, status: :not_found unless invitation

    render json: {
      email: invitation.email,
      company: {
        id: invitation.company.id,
        name: invitation.company.name
      }
    }
  end
  
  def accept
    invitation = Invitation.find_by(token: params[:token])

    unless invitation
      return redirect_to "#{ENV['FRONT_URL']}/invalid-invitation"
    end

    redirect_to "#{ENV['FRONTEND_URL']}/signup-from-invite?token=#{invitation.token}"
  end
end
