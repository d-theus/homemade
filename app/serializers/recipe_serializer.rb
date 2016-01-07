class RecipeSerializer < ActiveModel::Serializer
    attributes :id,
      :title,
      :subtitle,
      :cooking_time,
      :calories,
      :description,
      :day,
      :url
    has_many :inventory_items

    def url
      recipe_path(object) if object.id
    end
end
