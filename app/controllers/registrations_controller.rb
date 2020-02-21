class RegistrationsController < Devise::RegistrationsController
  after_action :create_job_search, only: [:create]

  def create_job_search
    user = User.find_by(email: params[:user][:email])
    if user.present?
      JobSearch.create(user_id: user.id, website_url: 'https://www.karriere.at', designation: 'project-manager', location: 'wien', job_search_type: 'static')
    end
  end

  def create
    if params[:user].present?
      user = User.new(user_params)
      if user.save
        user.answer=security_questions.find_index(params[:security_question]).to_s+params[:user][:answer]
        user.save
        sign_in user
        flash[:notice] = "Signup successfully."
        redirect_to user_dashboard_path
      end
    end
  end

  def update_user_details
      if params[:user][:answer].present?
        if params[:user][:answer] == current_user.answer.sub(current_user.answer.first,"")
          current_user.update(user_params)
          # Sidekiq.set_schedule(current_user.email, {  cron: cron_generator( params[:user][:package] , params[:dow] ),
          #                                             class: 'EmailWorker',
          #                                             queue:"mailers",
          #                                             args: current_user.id, 
          #                                             enabled: true })
          flash[:notice] = "User details succesfully updated!!!"
          redirect_to user_dashboard_path
        else
          flash[:alert] = "Answer does not match!!!"
          redirect_to edit_user_registration_path
        end
    else
      flash[:alert] = "Please enter the answer!!!"
      redirect_to edit_user_registration_path
    end
    
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :gender,:first_name, :last_name, :include_job1, :include_job2, :include_job3, :not_include_job1, :not_include_job2, :not_include_job3,:package)
  end


  def cron_generator(package,day)
    if (package == "Receive emails daily") 
      day="*"
      a="*"
    elsif package == "Receive email once a week"
      a="*"      
    else
      a="*/15"
    end
    "0 0 0 "+a+" * "+day.to_s
  end

  def job_id
    include_job = current_user.include_job1? || current_user.include_job2? || current_user.include_job3?

    not_include_job = current_user.not_include_job1? || current_user.not_include_job2? || current_user.not_include_job3?

    if (include_job && !not_include_job) || (include_job && not_include_job)
      job_data = Job.where("title = ? OR title = ? OR title = ?", current_user.include_job1, current_user.include_job2, current_user.include_job3)
    elsif !include_job && not_include_job
      job_data = Job.where.not("title = ? OR title = ? OR title = ?", current_user.not_include_job1, current_user.not_include_job2, current_user.not_include_job3)
    else
      job_data = Job.all
    end
  end

end
