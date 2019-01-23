class Api::V1::PromosController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    usercode = params["code"]
    @promo = Promo.where(code: usercode).first || {code: "unkown", percentage: "1"}
  end
end
