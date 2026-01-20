class InvitationMailer < ApplicationMailer
  default from: ENV["MAILJET_DEFAULT_FROM"]

  def invite_to_register(email:, inviter:, token:)
    @inviter_company_name = inviter.company&.name || "Une société"
    @invitee_email = email
    @token = token

    # Lien direct vers le front pour signup-request
    @accept_url = "#{ENV['FRONTEND_URL']}/signup-request?token=#{@token}&email=#{@invitee_email}"

    mail(to: email, subject: "Invitation à rejoindre Pall Tracker")
  end
end
