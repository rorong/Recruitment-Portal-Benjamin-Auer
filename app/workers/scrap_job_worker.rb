class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "scrap_job"

  def perform(*args)
    ScraperService.scrap_job(args)
  end
end
