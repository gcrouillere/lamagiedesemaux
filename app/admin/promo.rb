ActiveAdmin.register Promo do
  permit_params :code, :percentage
  config.filters = false
  actions  :index, :new, :create, :destroy, :update, :edit
  menu priority: 4

  index do
    column :code
    column :percentage
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :code
      f.input :percentage, :hint => "Nombre à virgule entre 0 et 1. Correspond à une réduction de 0 à 100%."
    end
    f.actions
  end

  controller do

   def create
      super do |format|
        redirect_to admin_promos_path and return if resource.valid?
      end
    end

    def destroy
      Order.where(promo_id: params[:id]).update_all(promo_id: nil)
      super do |format|
        redirect_to admin_promos_path and return
      end
    end

    def update
      super do |format|
        redirect_to admin_promos_path and return if resource.valid?
      end
    end

  end

end
