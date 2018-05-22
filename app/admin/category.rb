ActiveAdmin.register Category do
  permit_params :name, :category_ids
  config.filters = false
  actions  :index, :new, :create, :destroy, :update, :edit
  menu priority: 2

  index do
    column :name
    column "Sous-catégories" do |category|
      if category.categories.present?
        category.categories.inject("") {|sum, category| sum + "#{category.name} - "}[0..-3]
      end
    end
    actions
  end

  form do |f|
    f.inputs "" do
      f.input :name
      f.input :categories,  :label => "Sous-categories", :hint => "Sélectionnez les sous-catégories. Maintenez Ctrl appuyé pour en sélectionner plusieurs."
    end
    f.actions
  end

  controller do

   def create
      super do |format|
        if resource.valid?
          multi_category_assignment
        end
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
        if resource.valid?
          multi_category_assignment
        end
        redirect_to admin_categories_path and return if resource.valid?
      end
    end

    def multi_category_assignment
      params["action"] == "create" ? current_category = Category.last : current_category = Category.find(params[:id])
      sub_categories_ids = params["category"]["category_ids"].select{|s| s != ""}.map {|s| s.to_i}
      current_category.categories = Category.find(sub_categories_ids)
    end

  end

end
