ActiveAdmin.register User, as: 'Clients' do
  actions  :index, :show, :update, :edit
  permit_params :tracking
  menu priority: 7
  config.filters = false

  index do
    column "Origine - Prénom Nom" do |user|
      if user.first_name.include?("newsletter")
        "Newsletter - Inconnu"
      elsif user.last_name.include?("message")
        "Message via contact - #{user.first_name}"
      elsif user.admin
        "Administrateur - #{user.first_name} #{user.last_name}"
      else
        "Commande - " + user.first_name + " " + user.last_name
      end
    end
    column :email
    column "Dernier achat" do |user|
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        last_order = Order.where(user: user, state: "paid").order(updated_at: :desc).first
        last_order ? humanized_money(last_order.amount) + " € " + last_order.updated_at.strftime("le %d/%m/%Y") : "Aucun achat"
      end
    end
    column "Total des achats" do |user|
      total = 0
      user_orders = Order.where(user: user, state: "paid")
      nb_achat = Order.where(user: user, state: "paid").size
      user_orders.each do |order|
        total += order.amount
      end
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        nb_achat.to_s + " achat(s) : " + humanized_money(total) + " € "
      end
    end
    column "Nb de paniers abandonnés" do |user|
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        Order.where(user: user, state: "lost").size
      end
    end
    column "Dernier panier abandonné" do |user|
      last_lost_basket = Order.where(user: user, state: "lost").order(updated_at: :desc).first
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      elsif last_lost_basket
        contenu_panier = last_lost_basket.basketlines.map do |basketline|
          basketline.ceramique ? "#{basketline.ceramique.name} - qté: #{basketline.quantity}" : "/"
        end
        contenu_panier = contenu_panier.join(", ")
        if last_lost_basket.amount > 0
          humanized_money(last_lost_basket.amount) + " € " + last_lost_basket.updated_at.strftime("le %d/%m/%Y") + ". Il contenait: " + contenu_panier
        else
          "#{last_lost_basket.updated_at.strftime("le %d/%m/%Y")}, annulé par le client. Dernier item supprimé: #{last_lost_basket.ceramique}"
        end
      else
        "/"
      end
    end
    actions
  end

  show do |user|
    attributes_table do
      if user.admin
        row "Délai de livraison" do |user|
          user.tracking
        end
      elsif user.first_name.include?("newsletter")
      elsif user.last_name.include?("message")
        row :first_name
        row :email
        row "Utilisateur inscrit via : Contact" do |user|
          "Dernier message : " + user.tracking
        end
      else
        row "Dernier achat" do |user|
          last_order = Order.where(user: user, state: "paid").order(updated_at: :desc).first
          last_order ? humanized_money(last_order.amount) + " € " + last_order.updated_at.strftime("le %d/%m/%Y") : "Aucun achat"
        end
        row :first_name
        row :last_name
        row :email
        row "N° de suivi colis" do |user|
          user.tracking
        end
      end
    end
  end

  form do |f|
    @user = User.find(params[:id].to_i)
    f.inputs "" do
      f.input :first_name
      f.input :last_name
      f.input :email
      if @user.admin
        f.input :tracking, label: "Délai de livraison", :hint => "Entrez le délai de livraison sous la forme \"Nb de jour en chiffres (espace) durée\". Ex: 2 semaines"
      else
        f.input :tracking, :hint => "Entrez le numéro de suivi. Après validation il sera envoyé par mail au client"
      end
    end
    f.actions
  end

  controller do
     def update
      super do |format|
        @user = User.find(params[:id].to_i)
        puts "#{@user.email}"
        puts "#{@user.tracking}"
        unless @user.admin
          OrderMailer.send_tracking_after_order(@user).deliver_now
        end
        redirect_to admin_clients_path and return if resource.valid?
      end
    end
  end

  csv do
    column "Origine - Prénom Nom" do |user|
      if user.first_name.include?("newsletter")
        "Newsletter - Inconnu"
      elsif user.last_name.include?("message")
        "Message via contact - #{user.first_name}"
      elsif user.admin
        "Administrateur - #{user.first_name} #{user.last_name}"
      else
        "Commande - " + user.first_name + " " + user.last_name
      end
    end
    column :email
    column "Dernier achat" do |user|
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        last_order = Order.where(user: user, state: "paid").order(updated_at: :desc).first
        last_order ? humanized_money(last_order.amount) + " € " + last_order.updated_at.strftime("le %d/%m/%Y") : "Aucun achat"
      end
    end
    column "Total des achats" do |user|
      total = 0
      user_orders = Order.where(user: user, state: "paid")
      nb_achat = Order.where(user: user, state: "paid").size
      user_orders.each do |order|
        total += order.amount
      end
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        nb_achat.to_s + " achat(s) : " + humanized_money(total) + " € "
      end
    end
    column "Nb de paniers abandonnés" do |user|
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      else
        Order.where(user: user, state: "lost").size
      end
    end
    column "Dernier panier abandonné" do |user|
      last_lost_basket = Order.where(user: user, state: "lost").order(updated_at: :desc).first
      if user.first_name.include?("newsletter")
        "N/A : inscrit newsletter"
      elsif user.last_name.include?("message")
        "N/A : envoi message"
      elsif last_lost_basket
        contenu_panier = last_lost_basket.basketlines.map do |basketline|
          basketline.ceramique ? "#{basketline.ceramique.name} - qté: #{basketline.quantity}" : "/"
        end
        contenu_panier = contenu_panier.join(", ")
        if last_lost_basket.amount > 0
          humanized_money(last_lost_basket.amount) + " € " + last_lost_basket.updated_at.strftime("le %d/%m/%Y") + ". Il contenait: " + contenu_panier
        else
          "#{last_lost_basket.updated_at.strftime("le %d/%m/%Y")}, annulé par le client. Dernier item supprimé: #{last_lost_basket.ceramique}"
        end
      else
        "/"
      end
    end
  end

end
