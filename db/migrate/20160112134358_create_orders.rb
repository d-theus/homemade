class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :count, null: false
      t.string :payment_method, null: false
      t.string :status, default: 'new'
      t.string :name, null: false
      t.string :phone, null: false
      t.string :address, null: false
      t.string :interval, null: false
      t.boolean :by_phone, default: false

      t.timestamps
    end
  end
end
