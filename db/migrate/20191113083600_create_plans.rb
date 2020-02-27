class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.string :plan_id, null: false
      t.string :name
      t.string :interval
      t.string :interval_count
      t.integer :display_price

      t.timestamps
    end
  end
end
