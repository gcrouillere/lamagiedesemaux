class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :confirmation, :info, :contact, :google906057532e2dbb7e, :robots, :legal]

  def home
    @dev_redirection = "https://www.creermonecommerce.fr/"
    render "home_#{@active_theme.name}"
  end

  def confirmation
    render "confirmation_#{@active_theme.name}"
  end

  def info
    @dev_redirection = "https://www.creermonecommerce.fr/#anchor-info"
    render "info_#{@active_theme.name}"
  end

  def contact
    @dev_redirection = "https://www.creermonecommerce.fr/produits"
    render "contact_#{@active_theme.name}"
  end

  def legal
    @dev_redirection = "https://www.creermonecommerce.fr/produits"
  end

  def google906057532e2dbb7e
  end

  def robots
    render 'pages/robots.txt.erb'
    expires_in 6.hours, public: true
  end

end
