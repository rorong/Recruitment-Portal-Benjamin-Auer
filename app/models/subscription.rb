class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :package , optional: true
  after_create :initiate_job_email_notification

  def initiate_job_email_notification
    if package.present?
      case package.interval
        when "Daily"
          start_at = Date.today.end_of_day + 4.hours
          DailyEmailWorker.perform_at( start_at, self.user_id )
        when "Weekly"
          start_at = 0.weeks.from_now.next_occurring(Date::DAYNAMES[0].downcase.to_sym).end_of_day + 4.hours
          WeeklyEmailWorker.perform_at( start_at, self.user_id )
        when "Every 2 Weeks"
          start_at = 1.weeks.from_now.next_occurring(Date::DAYNAMES[0].downcase.to_sym).end_of_day + 4.hours
          TwoWeekEmailWorker.perform_at( start_at, self.user_id )
        when "Monthly"
          start_at = Date.today.end_of_month.end_of_day + 4.hours
          MonthlyEmailWorker.perform_at( start_at, self.user_id )
        when "Yearly"
          start_at = Date.today.end_of_month.end_of_day + 4.hours
          YearlyEmailWorker.perform_at( start_at, self.user_id )
      end
    end
  end
end
