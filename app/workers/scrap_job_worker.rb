class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"

  def perform(user_id)
  	designation=User.find(user_id).job_search.designation
  	location=User.find(user_id).job_search.location
    ScraperService.scrap_job(designation,location)
  end

end
