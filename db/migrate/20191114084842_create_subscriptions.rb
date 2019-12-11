class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.string :name, default: '', null: false
      t.string :email, default: '', null: false
      t.string :mobile, default: '', null: false
      t.string :expiry_date, default: '', null: false
      t.belongs_to :plan, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
