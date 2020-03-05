class JobMailer < ApplicationMailer
  default from: "from@example.com"

  def job_email(user)
    @user= user
    user_jobs = []
    included_keywords = [@user.include_job1, @user.include_job2, @user.include_job3].reject!(&:blank?)
    not_included_keywords = [@user.not_include_job1, @user.not_include_job2, @user.not_include_job3].reject!(&:blank?)

    if included_keywords.present?
      included_keywords.each do |keyword|
        user_jobs << jobs_for_included_keyword(keyword)
      end
    elsif not_included_keywords.present?
      not_included_keywords.each do |keyword|
        user_jobs << jobs_for_not_included_keyword(keyword)
      end
    else
      user_jobs << @user.jobs
    end

    if user_jobs.count > 0
      user_jobs.flatten!
      @jobs = user_jobs
    end
    mail(to: user.email, subject: 'Jobs') if user.present?
  end

  def jobs_for_included_keyword(keyword)
    jobs = @user.jobs.where("lower(title) ~* '#{keyword}\\M'")
    return jobs
  end

  def jobs_for_not_included_keyword(keyword)
    jobs = @user.jobs.where.not("lower(title) ~* '#{keyword}\\M'")
    return jobs
  end
end
