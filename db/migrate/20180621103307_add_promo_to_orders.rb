class AddPromoToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :promo, foreign_key: true
    remove_column :orders, :promo
  end
end
