class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @job_search=current_user.job_search
  end

  def update_job_detail
    job_search = current_user.job_search
    if job_search.update_attributes(job_search_params)
      Sidekiq.set_schedule("dynamic_scrap_worker", {
                                                      cron: "0 0 0 * * *",
                                                      class: 'DynamicScrapWorker',
                                                      queue:"default",
                                                      args: User.pluck(:id)
                                                    })

      Sidekiq.set_schedule("scrap_job_worker", {
                                                  cron: "0 0 0 * * *",
                                                  class: 'ScrapJobWorker',
                                                  queue:"default",
                                                  args: User.pluck(:id)
                                                })
      redirect_to user_dashboard_url , notice: "Job details successfully updated!!!"
    else
      redirect_to user_dashboard_url , alert: "Job details not updated!!!"
    end
  end

  def display_karriere
    @jobs =  current_user.jobs.karriere.paginate(page: params[:page], per_page: 15)
  end

  def display_derstandard
    @jobs =  current_user.jobs.derstandard.paginate(page: params[:page], per_page: 15)
  end



  private

  def job_search_params
    params.require(:job_search).permit(:designation, :location, :is_update)
  end


end
