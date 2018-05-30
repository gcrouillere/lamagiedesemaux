 class RenameTableBasket < ActiveRecord::Migration[5.0]
   def change
     rename_table :basketlines, :basket_lines
   end
 end
