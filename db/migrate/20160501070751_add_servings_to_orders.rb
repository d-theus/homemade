class AddServingsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :servings, :integer, null: false, default: 2
  end
end
