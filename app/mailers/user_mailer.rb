class UserMailer < ApplicationMailer
  default from: ENV["MAILJET_DEFAULT_FROM"]


# app/mailers/user_mailer.rb
def invite_email(invitation)
  @invitation = invitation

  # Lien direct vers le frontend Vue.js pour signup depuis invitation
  @accept_url = "#{ENV['FRONTEND_URL']}/signup-from-invite?token=#{@invitation.token}"

  mail(
    to: @invitation.email,
    subject: "Vous êtes invité(e) !"
  )
end


  def debt_summary(user)
    @user = user
    @records = user.palette_records.order(:week)
    @total_dette = @records.sum { |r| r.rendered.to_i - r.loaded.to_i }

    mail(
      to: @user.email,
      subject: "Résumé de votre dette palettes"
    )
  end

  def admin_invitation_email(user, temp_password)
    @user = user
    @temp_password = temp_password
    @login_url = "#{ENV['FRONTEND_URL']}/login"

    mail(
      to: @user.email,
      subject: "Votre compte admin a été créé"
    )
  end

    # email envoyé au visiteur suite au contact form
    def visitor_contact_email(params)
      @name = params[:name]
      @email = params[:email]
      @message = params[:message]
      @url = application_url
      mail(to:  @email, subject: "RAYM Marketplacet: Nous avons reçu votre message")
    end
end
