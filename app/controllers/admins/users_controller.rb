class Admins::UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :existing_plan, only: [:index]
  before_action :admin_stripe_api_key, only: [:create_plan,:update_plan,:delete_plan]

  def email_plan
    @package=Package.all
  end

  def update_email
    plan=Plan.find(params[:id])
    package=Package.find(params[:package])

    package.update(name:params[:package_name] , plan_id:plan.id , interval: params[:interval].to_i)
    redirect_to admins_email_path
  end

  def edit_email
    @package=Package.find(params[:id])
  end

  def new_plan
  end

  def create_plan

    product_id=ENV['stripe_product_id']
    plan= Stripe::Plan.create({
            amount: (params[:amount].to_i*100).to_s,
            currency: 'usd',
            nickname: params[:plan_name],
            interval: params[:interval],
            interval_count: params[:interval_count],
            product: product_id,
          })

    Plan.create(plan_id: plan.id,
                name: params[:plan_name] ,
                display_price: params[:amount] ,
                interval:params[:interval],
                interval_count:params[:interval_count])

    redirect_to admins_plan_path, notice: "Plan successfully created!!!"
  end

  def existing_plan
    @plan=Plan.all
  end

  def edit_plan
    @plan =Plan.find_by(plan_id:params[:id])
  end

  def update_plan
    if params[:id].present?

      Stripe::Plan.update(
        params[:id],
        {nickname: params[:plan_name]},
      )
      plan=Plan.find_by(plan_id: params[:id])
      plan.update(name:params[:plan_name])
      redirect_to admins_plan_path, notice: "Plan successfully updated!!!"
    else
      redirect_to admins_plan_path, notice: "No plan found!!!"
    end
  end

  def delete_plan
    if params[:id].present?

      @plan = Stripe::Plan.retrieve(params[:id])
      @plan.delete if @plan.present?
      Plan.find_by(plan_id: params[:id]).destroy
      redirect_to admins_plan_path, notice: "Plan successfully deleted!!!"
    else
      redirect_to admins_plan_path, notice: "No plan found!!!"
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
      user = User.new(user_params)
    if user.save
      #user.answer = security_questions.find_index(params[:security_question]).to_s+params.dig(:user, :answer)
      user.answer = params.dig(:user, :answer)
      user.save
      flash[:notice] = "User created."
    else
      flash[:notice] = "Something went wrong."
    end
    redirect_to admins_users_path
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
    current_user = User.find_by(email: params.dig(:user, :email))
    if current_user.present?
      current_user.update(user_params)
      flash[:notice] = "User details succesfully updated!!!"
      redirect_to admins_users_path
    else
      flash[:alert] = "User not found!!!"
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

  def interval_generator(interval,interval_count)
    if interval == "week"
      a=interval_count
    elsif interval == "month"
      a=4*interval_count
    elsif interval == "year"
      a=52
    else
      return interval_count.to_s+"d"
    end
      a=a.to_s+"w"
  end

  def first_mail
    date  = DateTime.parse("Sunday")
    delta = date > DateTime.now ? 0 : 7
    e=date + delta
    g=((e-DateTime.now)*24*60).to_i
    g.to_s+"m"
  end

  def admin_stripe_api_key
    Stripe.api_key = ENV['stripe_secret_key']
  end

end

