class CreatePackages < ActiveRecord::Migration[6.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.integer :interval
      t.belongs_to :plan, index: true

      t.timestamps
    end
  end
end
