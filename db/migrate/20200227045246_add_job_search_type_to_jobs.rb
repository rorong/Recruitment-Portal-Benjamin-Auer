class AddJobSearchTypeToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :job_search_type, :integer
  end
end
