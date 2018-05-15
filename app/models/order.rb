class Order < ApplicationRecord
  monetize :amount_cents
  monetize :port_cents
  has_many :basketlines
  belongs_to :user
  belongs_to :lesson

  validates_inclusion_of :take_away, in: [true, false]
end
