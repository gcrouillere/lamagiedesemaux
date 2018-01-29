ActiveAdmin.register Offer, as: 'Offres' do
  permit_params :title, :description, :showcased, :discount, :ceramique_id
  actions  :index, :destroy, :update, :edit, :show, :new, :create
  menu priority: 3
  config.filters = false

  index do
    column :title
    column :description
    column "En première page ?" do |offer|
      offer.showcased
    end
    column "Discount" do |offer|
      (offer.discount * 100).to_i.to_s + " %"
    end
    actions
  end

  show do
    attributes_table do
      row :title
      row :description
      row :showcased
      row :discount
      row "Produits contenus dans l'offre" do |offer|
        Ceramique.all.where(offer: offer).map {|ceramique| ceramique.name}.join(", ")
      end
    end
  end

  form do |f|
    f.inputs "" do
      f.input :title
      f.input :description
      f.input :showcased
      f.input :discount, :hint => "Nombre à virgule entre 0 et 1. Correspond à une réduction de 0 à 100%."
      f.input :ceramiques,  :label => "Produits", :hint => "Sélectionnez les produits auxquels l'offre s'applique. Maintenez Ctrl appuyé pour en sélectionner plusieurs."
    end
    f.actions
  end

  controller do

    def create
      super do |format|
        if resource.valid?
          ceramiques_offer_assignment
          multi_showcased_flash_alert
          showcase_unicity_application
        end
        redirect_to admin_offres_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        if resource.valid?
          ceramiques_offer_assignment
          multi_showcased_flash_alert
          showcase_unicity_application
        end
        redirect_to admin_offres_path and return if resource.valid?
      end
    end

    def destroy
      @offer = Offer.find(params[:id].to_i)
      @offer.ceramiques.each {|ceramique| ceramique.update(offer: nil)}
      super do |format|
        redirect_to admin_offres_path and return if resource.valid?
      end
    end

    # Helper methods
    def ceramiques_offer_assignment
      params["action"] == "create" ? current_offer = Offer.last : current_offer = Offer.find(params[:id])
      ceramiques_ids_with_offer = params["offer"]["ceramique_ids"].select{|s| s != ""}.map {|s| s.to_i}
      ceramiques_ids_with_offer.each do |id|
        Ceramique.find(id).update(offer: current_offer)
      end
      ceramiques_ids_without_offer = Ceramique.all.map {|ceramique| ceramique.id} - ceramiques_ids_with_offer
      ceramiques_ids_without_offer.each do |id|
        if Ceramique.find(id).offer == current_offer
          Ceramique.find(id).update(offer: nil)
        end
      end
    end

    def showcase_unicity_application
      params["action"] == "create" ? current_offer = Offer.last : current_offer = Offer.find(params[:id])
      if current_offer.showcased
        offers_to_update = Offer.all.map{|offer| offer.id} - [current_offer.id]
        offers_to_update.each do |id|
          Offer.find(id).update(showcased: false)
        end
      end
    end

    def multi_showcased_flash_alert
      params["action"] == "create" ? word = "créée" : word = "modifiée"
      if Offer.all.where(showcased: true).size > 1
        flash[:alert] = "Plusieurs offres comportaient le paramètre \"En première page\" coché. Pour n'avoir qu'une offre en première page, seule la dernière #{word} garde ce paramètre."
      end
    end

  end

end
