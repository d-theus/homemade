class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :topic, null: false
      t.text :text, null: false
      t.string :email, null: false
      t.string :name
      t.boolean :unread, null: false, default: true

      t.timestamps
    end
  end
end
