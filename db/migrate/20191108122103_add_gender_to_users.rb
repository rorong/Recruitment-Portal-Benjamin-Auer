class AddGenderToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :gender, :string
    add_column :users, :include_job1, :string
    add_column :users, :include_job2, :string
    add_column :users, :include_job3, :string
    add_column :users, :not_include_job1, :string
    add_column :users, :not_include_job2, :string
    add_column :users, :not_include_job3, :string
  end
end
