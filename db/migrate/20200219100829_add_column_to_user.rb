class AddColumnToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :package, :integer , default: 0
  end
end
