class CreateCategoriesCeramiques < ActiveRecord::Migration[5.2]
  def change
    create_table :categoriesceramiques do |t|
      t.references :category, foreign_key: true
      t.references :ceramique, foreign_key: true
      t.timestamps
    end
  end
end
