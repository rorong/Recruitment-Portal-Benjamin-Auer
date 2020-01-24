class Job < ApplicationRecord

  def self.remove_duplicate_jobs(duplicate_job_ids)
    if rejected_job_ids.present?
      connection = ActiveRecord::Base.connection
      connection.execute("DELETE from jobs where id IN (#{rejected_job_ids.join(',')})")
     end
  end

end
