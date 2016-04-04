class RemoveImageFromInventoryItemsAndAddFilename < ActiveRecord::Migration
  def change
    remove_column :inventory_items, :image
    add_column    :inventory_items, :filename, :string, null: false, default: 'no.svg'
  end
end
