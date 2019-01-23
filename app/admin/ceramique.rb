ActiveAdmin.register Ceramique, as: 'Produits' do
  permit_params :name, :description, :stock, :weight, :price_cents, :position, :category_id, :subcategory_id, photos: []
  menu priority: 1
  config.filters = false

  index do
    column :id
    column :position
    column :name
    column :description
    column :stock
    column :weight
    column "Catégories" do |ceramique|
      "#{ceramique.subcategory.category.name} - #{ceramique.subcategory.name}"
    end
    column :price_cents
    column "Nb de ventes - CA", :sortable => 'ceramique.basketlines.sum(:quantity)* ceramique.price' do |ceramique|
      "#{ceramique.basketlines.joins(:order).where.not("orders.state = ?", "lost").sum(:quantity)} - #{ceramique.basketlines.joins(:order).where.not("orders.state = ?", "lost").sum(:quantity) * ceramique.price} €"
    end
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :position
      f.input :name
      f.input :description
      f.input :stock
      f.input :weight, :hint => "Poids en grammes"
      f.input :subcategory, :as => :select, :collection => Subcategory.all.map{|subcategory| ["#{subcategory.category.name} - #{subcategory.name}", subcategory.id]}
      f.input :price_cents, :hint => "Prix en centimes d'euros. Ex: entrez 1200 pour un prix de 12 €"
      f.inputs "Images", class: 'product_images' do
        f.object.photos.each {|photo| img(src: cl_image_path(photo.path, :width=>250, :crop=>"scale"))} unless f.object.new_record?
        f.input :photos, :as => :formtastic_attachinary, :hint => "Sélectionnez les photos du produit. Maintenez Ctrl appuyé pour en sélectionner plusieurs."
      end
      f.actions
    end
  end

show do |ceramique|
  attributes_table do
    row :name
    row :description
    row :stock
    row :weight
    row :price_cents
    row :images do |ceramique|
      ceramique.photos.each do |photo|
        span img(src: cl_image_path(photo.path, :width=>250, :crop=>"scale"))
      end
    end
  end
 end

 csv do
    column :position
    column :name
    column :description
    column :stock
    column :weight
    column :category
    column :price_cents
    column "Nb de ventes - CA" do |ceramique|
      total = 0
      sum = 0
      ceramique.basketlines.each do |basketline|
        if basketline.order.state == "paid"
          total += basketline.quantity
        end
      end
      sum = total * ceramique.price
      "#{total} - #{sum} €"
    end
 end

  controller do


   def create
      super do |format|
        resource.update(category: resource.subcategory.category)
        if resource.valid?
          product_positions_management
          flash[:notice] = "Produit créé"
          redirect_to admin_produits_path and return
        else
          flash[:alert] = "Certains champs ont été oubliés ou ne sont pas correctement remplis. Voir ci-dessous."
        end
      end
    end

    def destroy
      if Order.where(state: ["pending","payment page"]).joins(:basketlines).where("basketlines.ceramique_id = ?", resource.id).present?
        flash[:alert] = "Ce produit est dans un panier dans le processus d'achat, vous ne pouvez pas le supprimer"
        redirect_to request.referrer and return
      else
        resource.basketlines.update(ceramique_id: nil)
        flash[:notice] = "#{ENV['MODEL'][0...-1].capitalize} supprimé"
      end
      super do |format|
        redirect_to admin_produits_path and return
      end
    end


    def update
      super do |format|
        resource.update(category: resource.subcategory.category)
        if resource.valid?
          product_positions_management
          flash[:notice] = "Produit mis à jour"
          redirect_to admin_produits_path and return
        else
          flash[:alert] = "Certains champs ont été oubliés ou ne sont pas correctement remplis. Voir ci-dessous."
        end
      end
    end

    def product_positions_management
      if params[:ceramique][:position].present?
        products_to_manage = Ceramique.where("position IS NOT NULL AND position >= ?", params[:ceramique][:position]).where.not(id: resource.id)
        products_to_manage.each {|product| product.update(position: product.position + 1)}
      end
    end

  end

end
