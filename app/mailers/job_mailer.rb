class JobMailer < ApplicationMailer
  default from: "from@example.com"

  def job_email(user, job_hash)
    @user = user
    @jobs = job_hash
    mail(to: @user.email, subject: 'Jobs')
  end
end
