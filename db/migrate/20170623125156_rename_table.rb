 class RenameTable < ActiveRecord::Migration[5.0]
   def change
     rename_table :baskets, :basketlines
   end
 end
