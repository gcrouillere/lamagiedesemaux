class PaymentsController < ApplicationController
  before_action :set_order, only: [:create, :new, :create_stripe_payment]
  before_action :logistic_check, only: [:new]

  def new
    if @order.state == "lost"
      flash[:notice] = t(:expired_basket)
      redirect_to ceramiques_path and return
    end

    @payment_theme = @active_theme.name
    final_order_amount
    @order.take_away ? @final_amount = @order.amount_cents : @final_amount = @order.amount_cents + @order.port_cents

    session = Stripe::Checkout::Session.create(
      customer_email: @order.user ? @order.user.email : "",
      payment_method_types: ['card'],
      line_items: [{
        name: 'ECOMMERCE BASE',
        description: "Paiement pour #{@order.ceramique || "lesson"}",
        amount: @final_amount,
        currency: 'eur',
        quantity: 1,
      }],
      success_url: payments_create_stripe_payment_url(order_id: @order.id),
      cancel_url: new_order_payment_url(@order),
    )

    @stripe_session = session["id"]
    @order.update(stripe_session: session["id"])
    @order.take_away ? @order_in_js = @order.amount_cents : @order_in_js = @order.amount_cents + @order.port_cents
    gon.order_in_js = @order_in_js.to_f / 100
  end

  def create_stripe_payment
    session = Stripe::Checkout::Session.retrieve(@order.stripe_session)
    payment_intent = Stripe::PaymentIntent.retrieve(session["payment_intent"])
    status = payment_intent["status"]

    if status == "succeeded"
      document_order_basketlines
      @order.update(stripe_payment_intent: payment_intent, state: 'paid', method: 'stripe')
      sends_mails_after_order
    else
      flash[:notice] = t(:payment_failure)
      redirect_to new_order_payment_url(@order)
    end
  end

  def create
    # STRIPE
    if @order.state == "lost"
      flash[:error] = t(:expired_no_payment)
      redirect_to ceramiques_path and return
    end

    if params[:method] == "paypal"
      if params[:status] == "success"
        @order.update(state: 'paid', method: "paypal")
        document_order_basketlines
        sends_mails_after_order
      end
    end
  end

  private

  def sends_mails_after_order
    @lesson =  @order.lesson
    unless @lesson.present?
      # SEND EMAILS
      @user = current_user
      @amount = @order.amount
      OrderMailer.confirmation_mail_after_order(@user, @order).deliver_now
      OrderMailer.mail_francoise_after_order(@user, @order).deliver_now
      # CLEAR SESSION AND REDIRECT TO CONFIRMATION
      session[:order] = nil
      redirect_to confirmation_path and return
    else
      # SEND EMAILS
      LessonMailer.mail_user_after_lesson_payment(@lesson, @user).deliver_now
      LessonMailer.mail_francoise_after_lesson_payment(@lesson, @user).deliver_now
      redirect_to stage_payment_confirmation_path and return
    end
  end

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
