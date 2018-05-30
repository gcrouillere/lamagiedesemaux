ActiveAdmin.register Order do
  actions  :index, :show
  config.filters = false

  index download_links: -> { params[:action] == 'show' ? [:pdf] : nil } do
    render 'order_stats'
    column "Date du paiement" do |order|
      order.updated_at.strftime("%d/%m/%Y")
    end
    column "Statut" do |order|
      "Payé"
    end
    column "Client" do |order|
      order.user.email
    end
    column "Total HT" do |order|
      "#{order.amount * (1 - ENV['TVA'].to_f)} €"
    end
    column "TVA" do |order|
      "#{order.amount * ENV['TVA'].to_f} €"
    end
    column "Frais de port" do |order|
      "#{order.port} €"
    end
    column "Total TTC + port" do |order|
      "#{order.amount + order.port} €"
    end
    actions do |order|
      item "Facture PDF", admin_order_path(order, :format => 'pdf'), class: "member_link"
    end
  end

  show do |order|
    attributes_table do
      row :state
      row :ceramique
      row :amount_cents
      row :port_cents
      render 'pdf_link', { order: order }
    end
  end

  controller do
    def show
      super do |format|
        format.pdf { render(pdf: "#{resource.id}.pdf") }
      end
    end

    def index
      super do |format|
        @orders = Order.where(state: "paid").order(updated_at: :desc).page(params[:page]).per(20)
        @last_month_orders = Order.where("state LIKE ? AND updated_at >= ?", "paid", Time.now - 30 * 3600 * 24).count
        @last_six_month_orders = Order.where("state LIKE ? AND updated_at >= ?", "paid", Time.now - 180 * 3600 * 24).count
        @categories_sales_data_six = categories_data(180)
        @categories_sales_data_one = categories_data(30)
      end
    end

    def categories_data(duration)
      categories_sales_data = {}
      Category.all.each do |category|
        sum = 0
        category.ceramiques.each do |ceramique|
          ceramique.offer ? discount = ceramique.offer.discount : discount = 0

          addition = Basketline.where("basketlines.updated_at >= ? AND ceramique_id = ?", Time.now - duration * 3600 * 24, ceramique.id)
            .left_outer_joins(:order).where("orders.state = ?", "paid").sum(:quantity) * ceramique.price * (1 - discount)

          if addition > 0
            categories_sales_data[category.id.to_s.to_sym] = {}
            categories_sales_data[category.id.to_s.to_sym][ceramique.id.to_s.to_sym] = {}
            categories_sales_data[category.id.to_s.to_sym][ceramique.id.to_s.to_sym][:"ceramique_sum"] = addition
            categories_sales_data[category.id.to_s.to_sym][ceramique.id.to_s.to_sym][:"ceramique_name"] = ceramique.name
            categories_sales_data[category.id.to_s.to_sym][ceramique.id.to_s.to_sym][:"ceramique_id"] = ceramique.id
          end

          sum += addition
        end
        if sum > 0
          categories_sales_data[category.id.to_s.to_sym][:"sum"] = sum
        end
      end
      categories_sales_data
    end

  end

end
