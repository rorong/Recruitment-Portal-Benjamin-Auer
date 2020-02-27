class DashboardsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :get_duplicate_jobs, only: [:display_karriere, :display_derstandard]
  require 'httparty'
  require 'nokogiri'
  require 'will_paginate/array'

  include DashboardsConcern

  def email_package
    current_user.update(package: params[:dow].to_i)
    redirect_to user_dashboard_path
  end

  def dashboard
    @user=current_user
    @job_search=current_user.job_search
    # @package=current_user.package
    # if ( User.packages[current_user.package] != 0 and User.packages[current_user.package] != 1 )
    #   schedule=Sidekiq.get_schedule.select { |k,v| k if k==current_user.email }
    #   days_of_week=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    #   @dow=days_of_week[schedule.values[0].values[0].last.to_i]
    # end
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

  def find_job_detail
    if params[:id].present?
      @job_search =
      if params[:job_search_type] == 'static'
        @static_job_search = JobSearch.find_by(id: params[:id])
      else
        @dynamic_job_search = JobSearch.find_by(id: params[:id])
      end
      respond_to do |format|
        format.js { render layout: false ,locals: {job_search: @job_search}}
      end
    end
  end

  def update_job_detail
    job_search=User.find(params[:job_search][:user_id]).job_search
    job_search.update_attributes( user_id: params[:job_search][:user_id], 
                                  designation: params[:job_search][:designation],
                                  location: params[:job_search][:location], 
                                  is_update: true )
    
    redirect_to user_dashboard_url , notice: "Job details successfully updated!!!"
  end

  def destroy_job_detail
    if params[:id].present?
      @job_search = JobSearch.find_by(id: params[:id])
      @job_search.destroy
      flash[:alert] = "Job details successfully destroy!!!"
      redirect_to root_path
    end
  end

  def display_karriere
    sort_job = Job.order(created_at: :desc)
    if sort_job.present?
      job = sort_job.select { |m|
        if m.url.present?
          m.url.include? "karriere"
        end
      }
      @jobs = job.paginate(page: params[:page], per_page: 15)
    end
  end

  def display_derstandard
    sort_job = Job.order(created_at: :desc)
    if sort_job.present?
      job = sort_job.select { |m|
        if m.url.present?
          m.url.include? "derstandard"
        end
      }
      @jobs = job.paginate(page: params[:page], per_page: 15)
    end
  end

  def seacrh_job
    if params[:Website] == "https://www.karriere.at"
      ScraperService.scrap_job(params) if params.present?
      redirect_to root_path
    else
      DynamicScraperService.dynamic_scrap(params) if params.present?
      redirect_to display_path
    end
  end

end
