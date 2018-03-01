class PaymentsController < ApplicationController
  before_action :set_order, only: [:create]

  def new
    set_order
    @payment_theme = @active_theme.name
  end

  def create
    # STRIPE
    @order = Order.find(params[:order_id])
    customer = Stripe::Customer.create(
      source: params[:stripeToken],
      email:  params[:stripeEmail]
    )

    charge = Stripe::Charge.create(
      customer:     customer.id,   # You should store this customer id and re-use it.
      amount:       @order.amount_cents, # or amount_pennies
      description:  "Payment for #{@order.ceramique || "lesson"}, for order #{@order.id}",
      currency:     @order.amount.currency
    )

    @order.update(payment: charge.to_json, state: 'paid')

    @lesson =  @order.lesson
    unless @lesson.present?
      # SEND EMAILS
      @user = current_user
      @amount = @order.amount
      OrderMailer.confirmation_mail_after_order(@user, @order, @amount).deliver_now
      OrderMailer.mail_francoise_after_order(@user, @order, @amount).deliver_now
      # CLEAR SESSION AND REDIRECT TO CONFIRMATION
      session[:order] = nil
      redirect_to confirmation_path
    else
      # SEND EMAILS
      LessonMailer.mail_user_after_lesson_payment(@lesson, @user).deliver_now
      LessonMailer.mail_francoise_after_lesson_payment(@lesson, @user).deliver_now
      redirect_to stage_payment_confirmation_path
    end

    # REDIRECT TO PAYMENT
    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_order_payment_path(@order)
  end

  private

  def set_order
    @order = Order.where(state: 'pending').find(params[:order_id])
    @order.update(user: current_user) unless @order.user
    if (/\A(F-)?(((2[A|B])|[0-8]{1}[0-9]{1})|(9{1}[0-5]{1}))[0-9]{3}\z/).match("#{current_user.zip_code}") == nil
      flash[:alert] = "Les livraisons ne sont possibles qu'en France métropolitaine. Modifiez votre adresse si vous souhaitez poursuivre."
      redirect_to edit_user_registration_path
    end
  end

end
