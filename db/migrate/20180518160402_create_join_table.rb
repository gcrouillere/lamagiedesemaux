class CreateJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table "category_connections", :force => true, :id => false do |t|
      t.integer "category_a_id", :null => false
      t.integer "category_b_id", :null => false
    end
  end
end
