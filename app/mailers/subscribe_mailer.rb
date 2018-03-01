class SubscribeMailer < ApplicationMailer

  def subscribe(user, admin)
    @user = user
    @admin = admin
    mail(to: @admin.email, subject: "Inscription à la newsletter")
  end

  def web_message(user, admin)
    @user = user
    @admin = admin
    mail(to: @admin.email, subject: "Message depuis la boutique en ligne")
  end

end
