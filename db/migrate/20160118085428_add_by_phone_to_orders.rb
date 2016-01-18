class AddByPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :by_phone, :bool
  end
end
