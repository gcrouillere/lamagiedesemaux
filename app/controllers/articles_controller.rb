class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def new
    @article = Article.new
  end

  def index
    @articles = Article.where("name LIKE ?", "%article%").order(updated_at: :desc)
  end

  def show
    @article = Article.find(params[:id])
    @comments = Article.where(name: "#{@article.id}-commentaire").order(updated_at: :desc)
    @twitter_url = request.original_url.to_query('url')
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      respond_to do |format|
        format.html { redirect_to request.referrer }
        format.js
      end
    end
  end

  def update
    @article = Article.find(params[:article][:id])
    @article.update(article_params)
    redirect_to request.referrer
  end

  def destroy
    @article = Article.find(params[:id])
    reference_article = Article.where(id: @article.name.to_i).first
    @article.destroy
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
  end

  private

  def article_params
    params.require(:article).permit(:content, :name, :user_id, :id, :page)
  end
end
