class JobMailer < ApplicationMailer
  default from: "from@example.com"

  def job_email(user)
    @user= user
    @jobs = Job.all
    # include_job = user.include_job1? || user.include_job2? || user.include_job3?

    # not_include_job = user.not_include_job1? || user.not_include_job2? || user.not_include_job3?

    # if (include_job && !not_include_job) || (include_job && not_include_job)
    #   @jobs = Job.where("title = ? OR title = ? OR title = ?", user.include_job1, user.include_job2, user.include_job3)
    # elsif !include_job && not_include_job
    #   @jobs = Job.where.not("title = ? OR title = ? OR title = ?", user.not_include_job1, user.not_include_job2, user.not_include_job3)
    # else
    #   @jobs = Job.all
    # end
    mail(to: user.email, subject: 'Jobs') if user.present? #&& @jobs.present?
  end
end
