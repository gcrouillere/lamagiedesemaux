class Promo < ApplicationRecord
  has_many :orders
  validates :code, presence: true
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message:'Doit être compris entre 0 et 1 inclus' }
end
