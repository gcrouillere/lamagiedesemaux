ActiveAdmin.register Subcategory do
  permit_params :name, :category_id
  config.filters = false
  actions  :index, :new, :create, :destroy, :update, :edit
  menu priority: 2

  index do
    column :name
    column "Catégorie" do |subcategory|
      subcategory.category.name
    end
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :name
      f.input :category
    end
    f.actions
  end

  controller do

   def create
      super do |format|
        redirect_to admin_subcategories_path and return if resource.valid?
      end
    end

    def destroy
      subcategory = Subcategory.find(params[:id].to_i)
      ceramiques = subcategory.ceramiques.size
      if ceramiques > 0
        flash[:alert] = "Cette sous-catégorie est toujours utilisée dans des produits. Impossible de la supprimer."
        redirect_to admin_subcategories_path and return
      end
      super do |format|
        redirect_to admin_subcategories_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_subcategories_path and return if resource.valid?
      end
    end

  end

end
