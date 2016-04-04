class RemoveImageFromInventoryItemsAndAddFilename < ActiveRecord::Migration
  def change
    remove_column :inventory_items, :image, :string
    add_column    :inventory_items, :filename, :string, null: false, default: 'no'
  end
end
