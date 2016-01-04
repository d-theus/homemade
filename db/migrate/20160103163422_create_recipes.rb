class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :subtitle
      t.integer :cooking_time
      t.integer :calories
      t.text :description

      t.timestamps
    end
  end
end
