class DashboardsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :get_duplicate_jobs, only: [:display_karriere, :display_derstandard]
  require 'httparty'
  require 'nokogiri'
  require 'will_paginate/array'

  include DashboardsConcern


  def dashboard
    @job_search=current_user.job_searches
    # @static_job_search = JobSearch.where(user_id: current_user.id, job_search_type: 'static').last if current_user.present?
    # @dynamic_job_search = JobSearch.where(user_id: current_user.id, job_search_type: 'dynamic').last if current_user.present?
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
    if params[:job_search][:user_id].present?
      job_search=User.find(params[:job_search][:user_id]).job_searches
      job_search.each do |job|
        job.update_attributes(user_id: params[:job_search][:user_id], designation: params[:job_search][:designation],location: params[:job_search][:location], is_update: true)
      end
      Sidekiq.set_schedule("dynamic_scrap_worker", { 
                                                      cron: "0 0 0 * * *",
                                                      class: 'DynamicScrapWorker',
                                                      queue:"default",
                                                      args: current_user.id 
                                                    })
      
      Sidekiq.set_schedule("scrap_job_worker", {
                                                cron: "0 0 0 * * *",
                                                class: 'ScrapJobWorker',
                                                queue:"default",
                                                args: current_user.id
                                              })
    
      redirect_to user_dashboard_url , notice: "Job details successfully updated!!!"
      # if params[:job_search_type] == 'static'
      #   @static_job_search = JobSearch.find_by(id: params[:id])
      #   @static_job_search.update_attributes(user_id: params[:job_search][:user_id], designation: params[:job_search][:designation],location: params[:job_search][:location], is_update: true)
      # else
      #   @dynamic_job_search = JobSearch.find_by(id: params[:id])
      #   @dynamic_job_search.update_attributes(user_id: params[:job_search][:user_id], designation: params[:job_search][:designation],location: params[:job_search][:location], is_update: true)
      # end
      #flash[:success]= "Job details successfully updated!!!"
    end
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
