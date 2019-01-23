class AddColumnToBasketlines < ActiveRecord::Migration[5.2]
  def change
    add_column :basketlines, :ceramique_name, :string
    add_column :basketlines, :ceramique_qty, :int
    add_monetize :basketlines, :basketline_price, currency: { present: false }
  end
end
