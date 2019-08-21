class AddColumnsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :stripe_session, :string
    add_column :orders, :stripe_payment_intent, :string
  end
end
