class AddColumnToCeramiques < ActiveRecord::Migration[5.2]
  def change
    add_reference :ceramiques, :subcategory, index: true
  end
end
