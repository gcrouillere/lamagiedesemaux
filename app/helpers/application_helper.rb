module ApplicationHelper

  def destroy_admin_user_session_path
    return "/#{ENV['MODEL']}"
  end

  def photo_update(variable, top, right, bottom, left, classe, texte)
    @variable = variable.to_sym
    @top = top
    @right = right
    @bottom = bottom
    @left = left
    @classe = classe
    @texte = texte
    render partial: "shared/photo_update"
  end

  def article_typing(article_name, orientation, variable, live_id, input_id)
    @name = article_name
    @orientation = orientation
    @article = retrieve_article(article_name) || Article.new
    instance_variable_set "@#{variable}".to_sym, Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {}).render(@article.content || "")
    @live_id = live_id
    @input_id = input_id
  end

  def article_display(article_name, orientation)
    @article = retrieve_article(article_name) || Article.new
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    @markdown = @markdown.render(@article.content || "")
  end

  def retrieve_article(article_name)
    user = User.where(admin: true).first
    user ? (user.articles.where(name: article_name).present? ? user.articles.where(name: article_name).first : nil ) : nil
  end

  def facebook_share_id(facebookid)
    @facebookid = facebookid
    render partial: "shared/socialbuttons"
  end

  def periodic_stat(duration)
    duration < 31 ? @text_duration = "#{duration} jours" : @text_duration = "#{duration / 30} mois"
    @duration = duration
    render partial: "admin/orders/stat_template"
  end

end
