class DynamicScrapWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"

  def perform
  	users=User.all
  	users.each do |user|
	    DynamicScraperService.dynamic_scrap(user.job_search.designation,user.job_search.location)
	end
  end

end
