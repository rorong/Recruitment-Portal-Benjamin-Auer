class ScrapJobWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "default"

  def perform
    # job_param = {}
    # data = eval(params)
    # job_param.merge!(data)
    ScraperService.scrap_job
  end

end
