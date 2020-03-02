class CreateTempJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :temp_jobs do |t|
      t.string :designation
      t.string :title
      t.string :company
      t.string :url
      t.string :location
      t.datetime :date
      t.text :content
      t.integer :job_search_type
      t.timestamps
    end
  end
end
