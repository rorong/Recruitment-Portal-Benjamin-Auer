class DashboardsController < ApplicationController
  require 'httparty'
  require 'nokogiri'
  require 'will_paginate/array'


  def index
    job = Job.select { |m| m.url.include? "karriere" }
    @jobs = job.paginate(page: params[:page], per_page: 16)
  end

  def display
    job = Job.select { |m| m.url.include? "derstandard" }
    @jobs = job.paginate(page: params[:page], per_page: 16)
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
