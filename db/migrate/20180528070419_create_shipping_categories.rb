class CreateShippingCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_categories do |t|
      t.string :name, null: false
      t.string :alpha2, null: false
      t.integer :weight, null: false

      t.timestamps
    end
  end
end
