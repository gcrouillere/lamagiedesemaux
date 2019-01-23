# Order Mailer Controller
class OrderMailer < ApplicationMailer
  # frozen_string_literal: true

  def confirmation_mail_after_order(user, order)
    @user = user
    @order = order
    productqty = @order.basketlines.sum(:quantity)
    model_count = productqty > 1 ? ENV['MODEL'] : ENV['MODEL'][0...-1]
    mail(
      to: @user.email,
      subject: "Confirmation de commande de #{model_count}"
    )
  end

  def mail_francoise_after_order(user, order)
    @user = user
    @order = order
    mail(to: ENV['EMAIL'].to_s, subject: 'Nouvelle commande recue')
  end

  def send_tracking_after_order(user)
    @user = user
    mail(to: @user.email, subject: 'Numéro de suivi pour votre colis')
  end

end
