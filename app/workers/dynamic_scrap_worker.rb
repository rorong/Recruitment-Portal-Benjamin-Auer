class DynamicScrapWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"


  def perform
    	DynamicScraperService.dynamic_scrap
  end

end
