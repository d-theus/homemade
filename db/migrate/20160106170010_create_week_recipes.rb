class CreateWeekRecipes < ActiveRecord::Migration
  def change
    create_table :week_recipes do |t|
      t.references :recipe, index: true
    end
  end
end
