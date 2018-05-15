class AddTakeawayToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :take_away, :boolean
    Order.update_all(take_away: false)
  end
end
