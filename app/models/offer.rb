class Offer < ApplicationRecord
  has_many :ceramiques

  validates :title, presence: true
  validates :description, presence: true
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message:'Doit être compris entre 0 et 1 inclus' }
end
