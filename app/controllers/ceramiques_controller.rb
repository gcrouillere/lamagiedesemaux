class CeramiquesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @dev_redirection = "http://www.guillaumecrouillere.fr"
    Offer.where(showcased: true).first ? (Offer.where(showcased: true).first.ceramiques.present? ? @front_offer = Offer.all.where(showcased: true).first : nil) : nil
    @front_offer ? @ceramiques_to_display_in_offer = Ceramique.all.where(offer: @front_offer) : nil
    clean_orders
    @ceramiques = Ceramique.all
    if params[:all].present?
      @ceramiques
    else
      filter_by_category if (params[:categories].present? || params[:subcategories].present?)
      filter_by_offer if params[:offer].present?
      filter_globally if params[:search].present?
      filter_by_price if params[:prix_max].present?
    end
    final_order
    @ceramique_1 = @ceramiques.first
    @twitter_url = request.original_url.to_query('url')
    @facebookid = ""
    render "index_#{@active_theme.name}"
  end

  def show
    session[:zoom_message] ? session[:zoom_message] += 1 : session[:zoom_message] = 0
    @dev_redirection = "http://www.guillaumecrouillere.fr"
    clean_orders
    @ceramique = Ceramique.find(params[:id])
    @same_category_products = Ceramique.where(subcategory: @ceramique.subcategory) - [Ceramique.find(@ceramique.id)]
    @twitter_url = request.original_url.to_query('url')
    render "show_#{@active_theme.name}"
  end

  def update
    @ceramique = Ceramique.find(params[:id])
    @fieldvalue =  @ceramique.send(get_editing_field)
    if @ceramique.update(ceramique_params)
      render json: @ceramique
    else
      render json: {id: @ceramique.id, fieldvalue: @fieldvalue, errors: @ceramique.errors}, status: :unprocessable_entity
    end
  end

  def update_positions_after_swap_in_admin
    params[:finalPositions].gsub("]","").gsub("[", "").split(",").map(&:to_i).each_with_index do |position, index|
      Ceramique.find(position).update(position: index + params[:startingPosition].to_i)
    end
    @ceramiques = Ceramique.all.order(position: :asc).order(updated_at: :desc)
    render json: @ceramiques
  end

  private

  def clean_orders
    Order.all.each do |order|
      if ((Time.now - order.created_at)/60/60 > ENV['BASKETDURATION'].to_f && order.state == "pending" && order.lesson.blank?) || ((Time.now - order.created_at)/60/60 > 24 && order.state == "payment page" && order.lesson.blank?)
        order.basketlines.each do |basketline|
          ceramique = basketline.ceramique
          ceramique.update(stock: ceramique.stock + basketline.quantity)
        end
        if session[:order]
          wip_local_order = Order.find(session[:order])
          session[:order] = nil if order == wip_local_order
        end
        order.update(state: "lost")
      end
    end
  end

  def filter_by_category
    @ceramiques_ids_by_category = []
    params["subcategories"].map(&:to_i).each {|id| @ceramiques_ids_by_category << Ceramique.where(subcategory: id).map(&:id)} if params["subcategories"]
    params["categories"].map(&:to_i).each {|id| @ceramiques_ids_by_category << Ceramique.where(category: id).map(&:id)} if params["categories"]
    @ceramiques_ids_by_category = @ceramiques_ids_by_category.flatten.uniq
    @ceramiques = Ceramique.where(id: @ceramiques_ids_by_category)
  end

  def filter_by_price
    @ceramiques = @ceramiques.joins(:offer).where("price_cents * (1 - discount) <= ? AND price_cents * (1 - discount) >= ? ", params[:prix_max].to_i * 100, params[:prix_min].to_i * 100) +
                  @ceramiques.where('offer_id IS NULL').where("price_cents <= ? AND price_cents >= ?", params[:prix_max].to_i * 100, params[:prix_min].to_i * 100)
  end

  def filter_by_offer
    @ceramiques = @ceramiques.where(offer: @front_offer)
  end

  def filter_globally
    raw_json = Ceramique.raw_search(params[:search])
    ceramiques_ids = raw_json["hits"].map {|hit| hit["objectID"].to_i}
    @ceramiques = @ceramiques.where(id: ceramiques_ids)
  end

  def final_order
    if params[:categories].present? || params[:subcategories].present?
      ordered_ids = @ceramiques_ids_by_category & @ceramiques.map(&:id)
      if ordered_ids.size > 0
        @ceramiques = Ceramique.where(id: ordered_ids).order(%Q{case id #{ordered_ids.map.each_with_index { |id, i| "when #{id} then #{i}" }.join(' ')} end })
      else
        @ceramiques = Ceramique.where(id: ordered_ids)
      end
    else
      @ceramiques = Ceramique.where(id: @ceramiques.map(&:id)).order(position: :asc).order(updated_at: :desc)
    end
  end

  def ceramique_params
    if params[:ceramique][:category].present?
      params.require(:ceramique).permit(:name, :stock, :weight, :price_cents, :description)
      .merge(subcategory_id: params[:ceramique][:category])
      .merge(category_id: Subcategory.find(params[:ceramique][:category]).category.id)
    else
      params.require(:ceramique).permit(:name, :stock, :weight, :price_cents, :description)
    end
  end

  def get_editing_field
    params.require(:ceramique).permit(:name, :stock, :weight, :price_cents, :description, :category).to_h.map {|k, v| k }.join
  end

end

