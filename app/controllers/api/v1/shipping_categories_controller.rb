class Api::V1::ShippingCategoriesController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    country = params["country"]
    weight = params["weight"]
    @shipping_category = ShippingCategory.where(alpha2: country).where("weight >= ?", weight).min
  end
end
