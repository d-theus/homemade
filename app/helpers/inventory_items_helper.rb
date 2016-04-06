module InventoryItemsHelper
  def inventory_item_tag(item, options = {})
    options.reverse_merge!({
      src: image_path(item.image.svg),
      title: item.name,
      class: :icon
    })
    capture_haml do
      haml_tag :img, options
    end
  end
end
