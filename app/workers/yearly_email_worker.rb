require 'sidekiq-scheduler'

class YearlyEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  sidekiq_options queue: "yearly_job_notification"

  def perform
    packages=Package.where(interval: 4)
    unless packages.blank?
      packages.each do |package|
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
