class CreateJobSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :job_searches do |t|
      t.integer :user_id
      t.string :website_url
      t.string :designation
      t.string :location
      t.string :job_search_type
      t.boolean :is_update, default: false
      t.timestamps
    end
  end
end
