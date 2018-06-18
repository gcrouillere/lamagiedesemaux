class Category < ApplicationRecord
  has_many :ceramiques
  has_many :subcategories

  validates :name, presence: true
end
