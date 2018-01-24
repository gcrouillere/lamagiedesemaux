class AppSpecificRegistration::RegistrationsController < Devise::RegistrationsController

  def update_resource(resource, params)
    if current_user.provider == "facebook"
      params.delete("password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  protected

  def after_update_path_for(resource)
    if session[:order].present? || session[:previous_url].include?("payments/new?order") || session[:previous_url].include?("lessons/")
      session[:previous_url]
    else
      root_path
    end
  end

end
