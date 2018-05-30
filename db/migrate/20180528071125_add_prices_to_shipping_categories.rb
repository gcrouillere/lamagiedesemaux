class AddPricesToShippingCategories < ActiveRecord::Migration[5.2]
  def change
    add_monetize :shipping_categories, :price, currency: { present: false }
  end
end
