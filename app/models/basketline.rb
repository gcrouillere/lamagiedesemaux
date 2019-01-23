class Basketline < ApplicationRecord
  belongs_to :ceramique
  belongs_to :order

  monetize :basketline_price_cents

  validates :quantity, numericality: { only_integer: true, greater_than: 0, }
end
