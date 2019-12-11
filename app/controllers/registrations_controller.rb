class RegistrationsController < Devise::RegistrationsController

  def create
    if params[:user].present?
      user = User.new(user_params)
      if user.save && params[:security_question].present?
        sq = SecurityQuestion.find_by(question: params[:security_question])
        user_question = user.security_questions.create(question: params[:security_question])
        answer = Answer.create(answer: params[:answer])
        user_question.answer = answer
        redirect_to root_path
      end
    end
  end

   def update
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
               flash[:alert] = "User Succesfully updated"
               redirect_to root_path
            else
               redirect_to edit_user_registration_path
            end
          else
            flash[:danger] = "Answer does not match"
            redirect_to edit_user_registration_path
          end
        else
          flash[:alert] = "Please enter the answer"
          redirect_to edit_user_registration_path
        end
      end
    else
      flash[:danger] = "Please select the security question"
      redirect_to edit_user_registration_path
    end

  end

  # protected

  # def update_resource(resource, params)
  #   return super if params["password"]&.present?
  #   resource.update_without_password(params.except(params))
  # end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :gender,:first_name, :last_name,
                                  :include_job1, :include_job2, :include_job3, :not_include_job1, :not_include_job2,
                                  :not_include_job3
                                )
  end

end
