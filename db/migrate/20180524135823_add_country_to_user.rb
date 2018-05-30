class AddCountryToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :country, :string, null: false, default: "FR"
  end
end
