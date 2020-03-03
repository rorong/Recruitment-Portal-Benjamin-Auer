require 'sidekiq-scheduler'

class WeeklyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "weekly_job_notification"

  def perform(*args)
    user = User.find_by(id: args[0])
    if user.present? && user.subscription.present?
      JobMailer.job_email(user).deliver_now
      schedule_next_weekly_job_email(user.id)
    end
  end

  def schedule_next_weekly_job_email(user_id)
    next_start_at = 0.weeks.from_now.next_occurring(Date::DAYNAMES[0].downcase.to_sym).end_of_day + 4.hours
    WeeklyEmailWorker.perform_at( next_start_at, user_id )
  end
end
