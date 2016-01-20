class AddIntervalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :interval, :string, null: :false
  end
end
