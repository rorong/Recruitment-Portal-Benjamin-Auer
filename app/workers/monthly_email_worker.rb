require 'sidekiq-scheduler'

class MonthlyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "monthly_job_notification"

  def perform(*args)
    user = User.find_by(id: args[0])
    if user.present? && user.subscription.present?
      JobMailer.job_email(user).deliver_now
      schedule_next_monthly_job_email(user.id)
    end
  end

  def schedule_next_monthly_job_email(user_id)
    next_start_at = Date.today.end_of_month.end_of_day + 4.hours
    MonthlyEmailWorker.perform_at( next_start_at, user_id )
  end

end
