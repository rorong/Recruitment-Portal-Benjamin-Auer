class RemoveFieldNameFromJobSearch < ActiveRecord::Migration[6.0]
  def change

    remove_column :job_searches, :job_search_type, :string
    remove_column :job_searches, :website_url, :string
  end
end
