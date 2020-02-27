class RegistrationsController < Devise::RegistrationsController
  # after_action :create_job_search, only: [:create]

  #Move in model callback
  # def create_job_search
  #   user = User.find_by(email: params[:user][:email])
  #   if user.present?
  #     JobSearch.create(user_id: user.id, designation: 'project-manager', location: 'wien')
  #   end
  # end

  def create
    user = User.new(user_params)

    if user.save
      #move it model callback
      user.answer = security_questions.find_index(params[:security_question]).to_s+params.dig(:user, :answer)

      #Remove it there should be only one call to db
      user.save
      sign_in user

      flash[:notice] = "Signup successfully."
    else
      flash[:notice] = "Something went wrong."
    end

    redirect_to user_dashboard_path
  end

  def update_user_details
    params.dig(:user, :answer)
    if params.dig(:user, :answer).present?
      if params.dig(:user, :answer) == current_user.answer.sub(current_user.answer.first,"")
        current_user.update(user_params)
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

  # def cron_generator(package,day)
  #   if (package == "Receive emails daily")
  #     day="*"
  #     a="*"
  #   elsif package == "Receive email once a week"
  #     a="*"
  #   else
  #     a="*/15"
  #   end
  #   "0 0 0 "+a+" * "+day.to_s
  # end

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
