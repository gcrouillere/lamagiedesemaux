class Subcategory < ApplicationRecord
  belongs_to :category
  has_many :ceramiques

  validates :name, presence: true
end
