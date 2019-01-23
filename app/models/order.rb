class Order < ApplicationRecord
  monetize :amount_cents
  monetize :port_cents
  has_many :basketlines
  belongs_to :promo, required: false
  belongs_to :user, required: false
  belongs_to :lesson, required: false

  validates_inclusion_of :take_away, in: [true, false]
end
