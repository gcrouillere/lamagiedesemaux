class Theme < ApplicationRecord
  validates :name, presence: true
  validates_inclusion_of :active, in: [true, false]
end
