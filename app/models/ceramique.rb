class Ceramique < ApplicationRecord
  include AlgoliaSearch
  extend FriendlyId

  algoliasearch do
    attribute :name, :description, :category
  end

  friendly_id :name, use: [:slugged, :finders]

  belongs_to :category
  belongs_to :offer
  has_attachments :photos, maximum: 4, dependent: :destroy
  has_many :basketlines, dependent: :destroy

  monetize :price_cents

  validates :photos, presence: true
  validates :category, presence: true
  validates :name, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0, less_than: 30001 , only_integer: true, message: 'Le poids doit être compris entre 1 et 30 000 grammes. Pas d\'expédition Colissimo possible en dehors de cette plage.' }
  validates :stock, presence: true, numericality: { only_integer: true , message:'Doit être un entier'}
  validates :price_cents, presence: true, numericality: { greater_than: 0 , message:'Doit être un entier supérieur à 0' }
  validates :description, presence: true
end
