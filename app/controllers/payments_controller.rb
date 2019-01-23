class PaymentsController < ApplicationController
  before_action :set_order, only: [:create, :new]
  before_action :logistic_check, only: [:new]

  def new
    @payment_theme = @active_theme.name
    final_order_amount
    if @order.state == "lost"
      flash[:notice] = t(:expired_basket)
      redirect_to ceramiques_path and return
    end
    @order.take_away ? @order_in_js = @order.amount_cents : @order_in_js = @order.amount_cents + @order.port_cents
    gon.order_in_js = @order_in_js.to_f / 100
  end

  def create
    # STRIPE
    if @order.state == "lost"
      flash[:error] = t(:expired_no_payment)
      redirect_to ceramiques_path and return
    end

    @order.take_away ? @final_amount = @order.amount_cents : @final_amount = @order.amount_cents + @order.port_cents

    if params[:method] == "stripe"
      customer = Stripe::Customer.create(
        source: params[:stripeToken],
        email:  params[:stripeEmail]
      )
      charge = Stripe::Charge.create(
        customer:     customer.id,   # You should store this customer id and re-use it.
        amount:       @final_amount, # or amount_pennies
        description:  "Payment for #{@order.ceramique || "lesson"}, for order #{@order.id}",
        currency:     @order.amount.currency
      )
      @order.update(payment: charge.to_json, state: 'paid', method: "stripe")
      document_order_basketlines
    elsif params[:method] == "paypal"
      if params[:status] == "success"
        @order.update(state: 'paid', method: "paypal")
        document_order_basketlines
      end
    end

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
    unless @order.lesson.present?
      costs = Amountcalculation.new(@order).calculate_amount(@order, current_user)
      @order.update(amount: costs[:total], port: costs[:port], weight: costs[:weight])
      params[:order] ? @promo = Promo.where(code: params[:order][:promo]).first : @promo = nil
      if @promo
        @order.update(amount: @order.amount * (1 - @promo.percentage), port: @order.port * (1 - @promo.percentage), promo: @promo)
      end
    end
  end

  def document_order_basketlines
    @order.basketlines.each do |basketline|
      @order.promo.present? ? order_discount = @order.promo.percentage : order_discount = 0
      if basketline.ceramique
        basketline.ceramique.offer ? ceramique_discount = basketline.ceramique.offer.discount : ceramique_discount = 0

        basketline.update(
          ceramique_name: basketline.ceramique.name,
          ceramique_qty: basketline.quantity,
          ceramique_id_on_order: basketline.ceramique.id,
          basketline_price: ((basketline.ceramique.price * (1 - ceramique_discount)) * basketline.quantity * (1 - order_discount))
          )
      end
    end
  end

end
