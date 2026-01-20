class UserConnectionMailer < ApplicationMailer
  default from: ENV["MAILJET_DEFAULT_FROM"]

  def invitation_email
    @connection = params[:connection]
    @requester = @connection.requester
    @receiver = @connection.receiver
    @role = @connection.role

    @dashboard_url = "#{ENV['FRONTEND_URL']}/dashboard"

    mail(
      to: @receiver.users.first.email,
      subject: "#{@requester.name} souhaite se connecter à votre entreprise"
    )
  end
end
