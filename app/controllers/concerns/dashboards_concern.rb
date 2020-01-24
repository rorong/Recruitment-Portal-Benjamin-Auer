module DashboardsConcern
  def get_duplicate_jobs
    @all_duplicate_jobs = Job.where(url: nil)

    duplicate_jobs_ids = @all_duplicate_jobs.pluck(:id)

    Job.remove_duplicate_jobs(duplicate_jobs_ids) if duplicate_jobs_ids.present?
  end
end
