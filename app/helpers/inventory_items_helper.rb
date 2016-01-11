module InventoryItemsHelper
  def inventory_item_tag(item)
    capture_haml do
      haml_tag :img,
        src: item.image,
        title: item.name
    end
  end
end
