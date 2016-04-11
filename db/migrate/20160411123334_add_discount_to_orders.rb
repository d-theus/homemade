class AddDiscountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount, :bool, default: false
  end
end
