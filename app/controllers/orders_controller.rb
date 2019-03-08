class OrdersController < ApplicationController

  skip_before_action :authenticate_user!, only: [:create, :show, :destroy]

  def create
    @ceramique = Ceramique.find(params[:ceramique].to_i)
    if session[:order].present?
      if Order.find(session[:order].to_i).state != "lost" && Order.find(session[:order].to_i).state != "paid"
        @order = Order.find(session[:order])
        @order.update(state: "pending")
      else
        @order = create_order
      end
    else
      @order = create_order
    end
    if params[:quantity].to_i <= @ceramique.stock
      @basketline = Basketline.create(ceramique: @ceramique, quantity: params[:quantity].to_i, order: @order)
      @ceramique.update(stock: @ceramique.stock - @basketline.quantity)
      costs = Amountcalculation.new(@order).calculate_amount(@order, current_user)
      @order.update(amount: costs[:total], port: costs[:port], ceramique: collect_ceramiques_for_stats, weight: costs[:weight])
      flash[:notice] = t(:basket_duration, duration: "#{(ENV['BASKETDURATION'].to_f * 60).to_i }")
      redirect_to order_path(@order)
    else
      flash[:alert] = t(:stock_limit, stock: "#{@ceramique.stock}")
      redirect_to ceramique_path(@ceramique)
    end
  end

  def show
    if Order.find(params[:id])
      @order = Order.find(params[:id])
      if @order.state == "pending" || @order.state == "payment page"
        if (current_user || @order.user.present?) && !@order.lesson.present?
          known_user = current_user || @order.user
          costs = Amountcalculation.new(@order).calculate_amount(@order, known_user)
          @order.update(amount: costs[:total], port: costs[:port], weight: costs[:weight], user: known_user)
        end
        @amount = @order.amount
        @port = @order.port
        @weight = @order.weight
        render "show_#{@active_theme.name}"
      else
        flash[:notice] = t(:expired_basket)
        redirect_to ceramiques_path
      end
    else
      flash[:notice] = t(:expired_basket)
      redirect_to ceramiques_path
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @basketline = Basketline.find(params[:basketline_id])
    @ceramique = @basketline.ceramique
    @ceramique.update(stock: @ceramique.stock + @basketline.quantity)
    @basketline.destroy
    costs = Amountcalculation.new(@order).calculate_amount(@order, current_user)
    @order.update(amount: costs[:total], port: costs[:port], weight: costs[:weight], ceramique: @order.ceramique.sub(@ceramique.name+",",""))
    if @order.basketlines.present?
      redirect_to order_path(@order)
    else
      @order.update(state: "lost")
      session[:order] = nil
      redirect_to ceramiques_path
    end
  end

  private

  def create_order
    order  = Order.new(ceramique: @ceramique.name, state: 'pending', take_away: false)
    order.save
    session[:order] = order.id
    return order
  end

  def collect_ceramiques_for_stats
    if @order.basketlines.size == 1
      "#{@ceramique.name}"
    else
      "#{@order.ceramique},#{@ceramique.name}"
    end
  end

end
