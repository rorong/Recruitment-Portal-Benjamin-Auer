class DynamicScrapWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "dynamic_scrapper_jobs"

  def perform
    DynamicScraperService.dynamic_scrap(User.pluck(:id))
  end
end
