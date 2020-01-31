class Admins::UsersController < ApplicationController
  before_action :authenticate_admin!
  after_action :create_job_search, only: [:create]
  before_action :existing_plan, only: [:index]

  def create_job_search
    user = User.find_by(email: params[:user][:email])
    if user.present?
      JobSearch.create(user_id: user.id, website_url: 'https://www.karriere.at', designation: 'project-manager', location: 'wien', job_search_type: 'static')
      JobSearch.create(user_id: user.id, website_url: 'https://jobs.derstandard.at', designation: 'project-manager', location: 'wien', job_search_type: 'dynamic')
    end
  end

  def new_plan
  end

  def create_plan
    Stripe.api_key = ENV['stripe_secret_key']
    product_id = ENV['stripe_product_id']
    Stripe::Plan.create({
      amount: params[:amount],
      currency: 'usd',
      nickname: params[:plan_name],
      interval: params[:interval],
      product: 'prod_GdAUyVxikWn9pG',
    })
    redirect_to admins_users_path, notice: "Plan successfully created!!!"
  end

  def existing_plan
    Stripe.api_key = ENV['stripe_secret_key']
    @plan = Stripe::Plan.all
  end

  def edit_plan
    Stripe.api_key = ENV['stripe_secret_key']
    @plan = Stripe::Plan.retrieve(params[:id])
  end

  def update_plan
    if params[:id].present?
      Stripe.api_key = ENV['stripe_secret_key']
      @plan = Stripe::Plan.retrieve(params[:id])
      Stripe::Plan.update(
        params[:id],
        {nickname: params[:plan_name]},
        {amount: params[:amount]},
      )
      redirect_to admins_users_path, notice: "Plan successfully updated!!!"
    else
      redirect_to admins_users_path, notice: "No plan found!!!"
    end
  end

  def delete_plan
    if params[:id].present?
      Stripe.api_key = ENV['stripe_secret_key']
      @plan = Stripe::Plan.retrieve(params[:id])
      @plan.delete if @plan.present?
      redirect_to admins_users_path, notice: "Plan successfully deleted!!!"
    else
      redirect_to admins_users_path, notice: "No plan found!!!"
    end
  end

  def index
    @users = User.all
    @users = @users.paginate(page: params[:page], per_page: 10) if @users.present?
  end

  def new
    @user = User.new
  end

  def create
    if params[:user].present?
      user = User.new(user_params)
      if user.save! && params[:security_question].present?
        sq = SecurityQuestion.find_by(question: params[:security_question])
        user_question =  user.security_questions << sq if sq
        answer = Answer.create(answer: params[:answer].downcase)
        user_question.last.answer = answer
        session[:user_id] = user.id
        user.update_attributes(admin_id: current_admin.id) if current_admin.present?
        flash[:notice] = "Signup in successfully."
        redirect_to admins_users_path
      end
    end
  end

  def show
    if params[:id].present?
      @user = User.find_by(id: params[:id])
    end
  end

  def edit
    if params[:id].present?
      @user = User.find_by(id: params[:id])
    end
  end

  def update
    if  params[:id].present? && params[:security_question].present?
      sq = SecurityQuestion.find_by(question: params[:security_question])
      current_user = User.find_by(id: params[:id])
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
              flash[:notice] = "User details succesfully updated!!!"
              redirect_to admins_users_path
            else
              redirect_to edit_admins_user_path
            end
          else
            flash[:alert] = "Answer does not match!!!"
            redirect_to edit_admins_user_path
          end
        else
          flash[:alert] = "Please enter the answer!!!"
          redirect_to edit_admins_user_path
        end
      else
        flash[:alert] = "Please select your security question!!!"
        redirect_to edit_admins_user_path
      end
    else
      flash[:alert] = "Please select the security question!!!"
      redirect_to edit_admins_user_path
    end
  end

  def destroy
    if params[:id].present?
      user = User.find_by(id: params[:id])
      user.destroy
      flash[:notice] = "User succesfully destroyed!!!"
      redirect_to admins_users_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :gender,:first_name, :last_name, :include_job1, :include_job2, :include_job3, :not_include_job1, :not_include_job2, :not_include_job3)
  end
end

