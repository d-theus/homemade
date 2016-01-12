class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :count, null: false
      t.string :payment_method, null: false
      t.integer :customer_id, null: false
      t.string :status, default: 'new'

      t.timestamps
    end
  end
end
