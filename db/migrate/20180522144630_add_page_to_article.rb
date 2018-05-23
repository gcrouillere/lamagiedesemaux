class AddPageToArticle < ActiveRecord::Migration[5.0]
  def change
    add_column :articles, :page, :string
  end
end
