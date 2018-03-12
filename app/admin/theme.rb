ActiveAdmin.register Theme do
  actions  :index, :update, :edit
  permit_params :active
  menu priority: 8
  config.filters = false

    index do
      column "Thème" do |theme|
        theme.name == "default" ? "Couleur - thème par défaut" : (theme.name == "darktheme" ? "Dark" : "Epuré")
      end
      column "Actif ?" do |theme|
        theme.active
      end
      actions
    end

  form do |f|
    f.inputs "" do
      f.input :active
    end
    f.actions
  end

  controller do

    def update
      current_theme = Theme.find(params[:id])
      if params[:theme][:active] == "0"
        Theme.all.update(active: false)
        Theme.where(name: "default").update(active: true)
        if current_theme.name == "default"
          flash[:alert] = "Pour activer le thème de votre choix, éditer le en cochant la case \"Actif ?\". Vous ne pouvez pas désactiver le thème par défaut."
        end
      end
      if params[:theme][:active] == "1"
        Theme.all.update(active: false)
        current_theme = Theme.find(params[:id])
        current_theme.update(active: true)
      end
      redirect_to admin_themes_path and return if resource.valid?
    end

  end

end
