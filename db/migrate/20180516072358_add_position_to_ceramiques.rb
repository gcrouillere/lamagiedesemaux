class AddPositionToCeramiques < ActiveRecord::Migration[5.0]
  def change
    add_column :ceramiques, :position, :integer
  end
end
