ActiveAdmin.register Category do
  permit_params :name
  config.filters = false
  actions  :index, :new, :create, :destroy, :update, :edit
  menu priority: 2, url: -> { admin_categories_path(locale: I18n.locale) }

  index do
    column :name
    column "Catégorie" do |category|
      category.subcategories.map {|subcategory| subcategory.name}.join(", ")
    end
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :name
    end
    f.actions
  end

  controller do

   def create
      super do |format|
        redirect_to admin_categories_path and return if resource.valid?
      end
    end

    def destroy
      category = Category.find(params[:id].to_i)
      ceramiques = category.ceramiques.size
      if ceramiques > 0
        flash[:alert] = "Cette catégorie est toujours utilisée dans des produits. Impossible de la supprimer."
        redirect_to admin_categories_path and return
      end
      super do |format|
        redirect_to admin_categories_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_categories_path and return if resource.valid?
      end
    end

  end

end
