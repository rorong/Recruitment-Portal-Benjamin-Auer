require 'sidekiq-scheduler'

class YearlyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "yearly_job_notification"

  def perform(*args)
    user = User.find_by(id: args[0])
    if user.present? && user.subscription.present?
      JobMailer.job_email(user).deliver_now
      schedule_next_yearly_job_email(user.id)
    end   
  end

  def schedule_next_yearly_job_email(user_id)
    next_start_at = Date.today.end_of_year.end_of_day + 4.hours
    YearlyEmailWorker.perform_at( next_start_at, user_id )
  end  
end
