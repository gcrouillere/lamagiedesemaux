 class DropTableBasketlines < ActiveRecord::Migration[5.0]
   def change
     drop_table :basket_lines
   end
 end
