class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"

  def perform(user_id)
  	designation=User.find(user_id).job_searches.find_by(job_search_type:"dynamic").designation
  	location=User.find(user_id).job_searches.find_by(job_search_type:"dynamic").location
    ScraperService.scrap_job(designation,location)
  end

end
