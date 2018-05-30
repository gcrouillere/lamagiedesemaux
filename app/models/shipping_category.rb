class ShippingCategory < ApplicationRecord
  has_many :country_datas
  validates :name, presence: true
end
