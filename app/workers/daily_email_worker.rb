require 'sidekiq-scheduler'

class DailyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "mailers"

  def perform
  	daily_packages=Package.where(interval: 0)
  	
  	unless daily_packages.blank?
	  	
	  	daily_packages.each do |package|
	  		
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
