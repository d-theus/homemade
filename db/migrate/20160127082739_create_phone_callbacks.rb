class CreatePhoneCallbacks < ActiveRecord::Migration
  def change
    create_table :phone_callbacks do |t|
      t.string :phone
      t.string :name
      t.boolean :pending, default: true

      t.timestamps
    end
  end
end
