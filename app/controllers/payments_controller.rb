class PaymentsController < ApplicationController
  before_action :set_order, only: [:create, :new]
  before_action :logistic_check, only: [:new]

  def new
    @payment_theme = @active_theme.name
    final_order_amount
    if @order.state == "lost"
      flash[:notice] = "Votre panier a expiré"
      redirect_to ceramiques_path and return
    end
  end

  def create
    # STRIPE
    if @order.state == "lost"
      flash[:error] = "Votre panier a expiré, la commande est annulée. Votre CB n'a pas été débitée."
      redirect_to ceramiques_path and return
    end
    customer = Stripe::Customer.create(
      source: params[:stripeToken],
      email:  params[:stripeEmail]
    )

    @order.take_away ? @final_amount = @order.amount_cents : @final_amount = @order.amount_cents + @order.port_cents

    charge = Stripe::Charge.create(
      customer:     customer.id,   # You should store this customer id and re-use it.
      amount:       @final_amount, # or amount_pennies
      description:  "Payment for #{@order.ceramique || "lesson"}, for order #{@order.id}",
      currency:     @order.amount.currency
    )

    @order.update(payment: charge.to_json, state: 'paid')
    @lesson =  @order.lesson
    unless @lesson.present?
      # SEND EMAILS
      @user = current_user
      @amount = @order.amount
      OrderMailer.confirmation_mail_after_order(@user, @order).deliver_now
      OrderMailer.mail_francoise_after_order(@user, @order).deliver_now
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
    @order = Order.find(params[:order_id])
    @order.update(state: "payment page") unless @order.state == "lost"
    @order.update(user: current_user) unless @order.user
  end

  def logistic_check
    params[:take_away] == "on" ? @order.update(take_away: true) : @order.update(take_away: false)
  end

  def final_order_amount
    costs = Amountcalculation.new(@order).calculate_amount(@order, current_user)
    @order.update(amount: costs[:total], port: costs[:port], weight: costs[:weight])
  end

end
