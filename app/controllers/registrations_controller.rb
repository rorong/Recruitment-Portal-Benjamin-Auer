class RegistrationsController < Devise::RegistrationsController
  after_action :create_job_search, only: [:create]

  def create_job_search
    user = User.find_by(email: params[:user][:email])
    if user.present?
      JobSearch.create(user_id: user.id, designation: 'project-manager', location: 'wien')
    end
  end

  def create
    if params[:user].present?
      user = User.new(user_params)
      if user.save && params[:security_question].present?
        sq = SecurityQuestion.find_by(question: params[:security_question])
        # user_question = user.security_questions.create(question: params[:security_question])
        user_question =  user.security_questions << sq if sq
        answer = Answer.create(answer: params[:answer].downcase)
        user_question.last.answer = answer
        session[:user_id] = user.id
        flash[:notice] = "Signup in successfully."
        redirect_to root_path
      end
    end
  end

  def update_user_details
    if params[:security_question].present?
      sq = SecurityQuestion.find_by(question: params[:security_question])
      if current_user.security_questions.pluck(:question).include? sq.question
        if params[:answer].present?
          saved_anwer = current_user.security_questions.find_by(question: params[:security_question])
          if saved_anwer.present? && saved_anwer.answer.try(:answer).try(:downcase) == params[:answer]
            current_user.gender = params[:gender]
            current_user.include_job1 = params[:include_job1]
            current_user.include_job2 = params[:include_job2]
            current_user.include_job3 = params[:include_job3]
            current_user.not_include_job1 = params[:not_include_job1]
            current_user.not_include_job2 = params[:not_include_job2]
            current_user.not_include_job3 = params[:not_include_job3]
            if current_user.update(user_params)
              Sidekiq.set_schedule(current_user.email, { cron: cron_generator( params[:package] , params[:dow] ),
                                                          class: 'EmailWorker',queue:"mailers",args: current_user.id })

              flash[:notice] = "User details succesfully updated!!!"
              redirect_to user_dashboard_path
            else
              redirect_to edit_user_registration_path
            end
          else
            flash[:alert] = "Answer does not match!!!"
            redirect_to edit_user_registration_path
          end
        else
          flash[:alert] = "Please enter the answer!!!"
          redirect_to edit_user_registration_path
        end
      else
        flash[:alert] = "Please select your security question!!!"
        redirect_to edit_user_registration_path
      end
    else
      flash[:alert] = "Please select the security question!!!"
      redirect_to edit_user_registration_path
    end
  end


  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :gender,:first_name, :last_name, :include_job1, :include_job2, :include_job3, :not_include_job1, :not_include_job2, :not_include_job3)
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
