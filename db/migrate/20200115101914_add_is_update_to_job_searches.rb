class AddIsUpdateToJobSearches < ActiveRecord::Migration[6.0]
  def change
    add_column :job_searches, :is_update, :boolean, default: false
  end
end
