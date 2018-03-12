class ErrorsController < ApplicationController
skip_before_action :authenticate_user!, only: [:error_404]
  layout 'error'

  def error_404
    render status: 404
  end

end
