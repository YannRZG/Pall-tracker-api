class UserMailer < ApplicationMailer
  default from: ENV['MAILJET_DEFAULT_FROM']


# app/mailers/user_mailer.rb
  def invite_email(invitation)
    @invitation = invitation
    # Génère l'URL complète avec host
    @accept_url = accept_invitation_url(
      token: @invitation.token,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
    mail(to: @invitation.email, subject: "Vous êtes invité(e) !")
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

    # email envoyé au visiteur suite au contact form
    def visitor_contact_email(params)
      @name = params[:name]
      @email = params[:email]
      @message = params[:message]
      @url = application_url
      mail(to:  @email, subject: 'RAYM Marketplacet: Nous avons reçu votre message')
    end
end
