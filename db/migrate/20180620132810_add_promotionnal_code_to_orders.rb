class AddPromotionnalCodeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :promo, :string
  end
end
