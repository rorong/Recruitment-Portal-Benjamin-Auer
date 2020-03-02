class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "scrapper_jobs"

  def perform
    #ScraperService.scrap_job(User.pluck(:id))
    ScraperService.scrap_job
  end
end
