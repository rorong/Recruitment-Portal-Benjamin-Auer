class DynamicScrapWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "dynamic_scrap_worker"


  def perform(*args)
    DynamicScraperService.dynamic_scrap(args)
  end

end
