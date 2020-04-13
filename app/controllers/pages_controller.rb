class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :confirmation, :info, :contact, :google906057532e2dbb7e, :robots, :legal, :cgv, :temoignages, :agenda, :sites_partenaires]

  def home
    @dev_redirection = "http://www.guillaumecrouillere.fr"
    render "home_#{@active_theme.name}"
  end

  def confirmation
    render "confirmation_#{@active_theme.name}"
  end

  def info
    @dev_redirection = "http://www.guillaumecrouillere.fr"
    render "info_#{@active_theme.name}"
  end

  def temoignages
    @article = Article.new
    @articles = Article.where(page: "temoignages").order(created_at: :desc)
    @dev_redirection = "http://www.guillaumecrouillere.fr"
  end

  def sites_partenaires
    @dev_redirection = "http://www.guillaumecrouillere.fr"
  end

  def agenda
    @dev_redirection = "http://www.guillaumecrouillere.fr"
  end

  def contact
    @dev_redirection = "http://www.guillaumecrouillere.fr"
    render "contact_#{@active_theme.name}"
  end

  def legal
    @dev_redirection = "http://www.guillaumecrouillere.fr"
  end

  def cgv
    @dev_redirection = "http://www.guillaumecrouillere.fr"
  end

  def google906057532e2dbb7e
  end

  def robots
    render 'pages/robots.txt.erb'
    expires_in 6.hours, public: true
  end

end
