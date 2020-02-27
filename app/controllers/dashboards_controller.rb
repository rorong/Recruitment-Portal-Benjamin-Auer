class DashboardsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def email_package
    current_user.update(package: params[:dow].to_i)
    redirect_to user_dashboard_path
  end

  def dashboard
    @user=current_user
    @job_search=current_user.job_search
    @plans=Plan.all
    @subscription=nil
    @subscription=current_user.subscription unless current_user.stripe_id.nil?
  end

  def create_job_detail
    if params[:job_search].present?
      @job_search = JobSearch.create(user_id: params[:job_search][:user_id], website_url: params[:job_search][:website_url],designation: params[:job_search][:designation],location: params[:job_search][:location])
      @job_search.save
      redirect_to root_path, notice: "Job details successfully created!!!"
    end
  end

  def update_job_detail
    job_search = current_user.job_search
    job_search.update_attributes(job_search_params)
    
    redirect_to user_dashboard_url , notice: "Job details successfully updated!!!"
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
