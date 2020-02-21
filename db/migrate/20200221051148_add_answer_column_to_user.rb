class AddAnswerColumnToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :answer, :string
  end
end
