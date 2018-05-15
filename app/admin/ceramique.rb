ActiveAdmin.register Ceramique, as: 'Produits' do
  permit_params :name, :description, :stock, :weight, :category_id, :price_cents, photos: []
  menu priority: 1
  config.filters = false

  index do
    column :id
    column :name
    column :description
    column :stock
    column :weight
    column "Catégorie" do |ceramique|
      ceramique.category.name
    end
    column :price_cents
    column "Nb de ventes - CA", :sortable => 'ceramique.basketlines.sum(:quantity)* ceramique.price' do |ceramique|
      "#{ceramique.basketlines.sum(:quantity)} - #{ceramique.basketlines.sum(:quantity) * ceramique.price} €"
    end
    actions
  end

  form do |f|
  f.inputs "" do
    f.input :name
    f.input :description
    f.input :stock
    f.input :weight, :hint => "Poids en grammes"
    f.input :category
    f.input :price_cents, :hint => "Prix en centimes d'euros. Ex: entrez 1200 pour un prix de 12 €"
    f.input :photos, :as => :formtastic_attachinary, :hint => "Sélectionnez les photos du produit. Maintenez Ctrl appuyé pour en sélectionner plusieurs."
  end
  f.actions
 end

show do |ceramique|
  attributes_table do
    row :name
    row :description
    row :stock
    row :weight
    row "Categorie" do |ceramique|
      ceramique.category.name
    end
    row :price_cents
    row :images do |ceramique|
      ceramique.photos.each do |photo|
        span img(src: "http://res.cloudinary.com/#{ENV['CLOUDINARY_NAME']}/image/upload/#{photo.path}")
      end
    end
  end
 end

 csv do
    column :name
    column :description
    column :stock
    column :weight
    column "Catégorie" do |ceramique|
      ceramique.category.name
    end
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
      if resource.valid?
        flash[:notice] = "Produit mis à jour"
        redirect_to admin_produits_path and return
      else
        flash[:alert] = "Certains champs ont été oubliés ou ne sont pas correctement remplis. Voir ci-dessous."
      end
    end
  end

  def destroy
    flash[:notice] = "#{ENV['MODEL'][0...-1].capitalize} supprimé"
    super do |format|
      redirect_to admin_produits_path and return
    end
  end

  def update
    super do |format|
      if resource.valid?
        flash[:notice] = "Produit mis à jour"
        redirect_to admin_produits_path and return
      else
        flash[:alert] = "Certains champs ont été oubliés ou ne sont pas correctement remplis. Voir ci-dessous."
      end
    end
  end

  end

end
