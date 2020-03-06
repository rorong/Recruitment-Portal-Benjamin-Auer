require 'sidekiq-scheduler'

class DailyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "daily_job_notification"

  def perform(*args)
    user = User.find_by(id: args[0])
    if user.present? && user.subscription.present?
      JobMailer.job_email(user).deliver_now
      schedule_next_daily_job_email(user.id)
    end
  end

  def schedule_next_daily_job_email(user_id)
    test_start_at = Time.now + 1.minutes
    #next_start_at = Date.today.end_of_day + 4.hours
    DailyEmailWorker.perform_at( test_start_at, user_id )
  end
end
