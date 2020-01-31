class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"

  def perform
    ScraperService.scrap_job
  end

end
