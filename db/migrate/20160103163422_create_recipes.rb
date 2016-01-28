class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :subtitle
      t.integer :cooking_time
      t.integer :calories
      t.string :photo
      t.string :picture
      t.integer :day, default: nil, limit: 1

      t.timestamps
    end

    add_index  :recipes, :day, unique: true
  end
end
