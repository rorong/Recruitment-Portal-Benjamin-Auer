require 'sidekiq-scheduler'

class WeeklyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "mailers"

  def perform
  	weekly_packages=Package.where(interval: 1)
  	
  	unless weekly_packages.blank?
	  	
	  	weekly_packages.each do |package|
	  		
	  		users=package.users

	  		unless users.blank?

	  			users.each do |user|

	  				JobMailer.job_email(user).deliver_now if user.subscription.present?
  

	  			end

	  		end

	  	end
  	
  	end
  end

end
