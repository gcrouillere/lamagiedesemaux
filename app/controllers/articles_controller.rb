class ArticlesController < ApplicationController

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
    @article = Article.find(params[:article][:id]).update(article_params)
    redirect_to request.referrer
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
