class RemoveCategoriesColumn < ActiveRecord::Migration[5.2]
  def change
    drop_table :category_connections
    drop_table :categoriesceramiques
  end
end
