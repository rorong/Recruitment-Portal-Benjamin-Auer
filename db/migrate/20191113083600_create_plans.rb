class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.string :stripe_id, null: false
      t.string :name
      t.decimal :display_price

      t.timestamps
    end
  end
end
