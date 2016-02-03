class CreateWeeklyMenuSubscriptions < ActiveRecord::Migration
  def change
    create_table :weekly_menu_subscriptions do |t|
      t.string :email, null: false, unique: true
      t.string :token, null: false

      t.timestamps
    end
  end
end
