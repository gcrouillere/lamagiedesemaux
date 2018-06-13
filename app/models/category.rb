class Category < ApplicationRecord
  has_many :ceramiques
  has_and_belongs_to_many(:categories,
  :join_table => "category_connections",
  :foreign_key => "category_a_id",
  :association_foreign_key => "category_b_id")

  validates :name, presence: true
end
