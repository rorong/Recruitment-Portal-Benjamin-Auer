class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :redirect_to_signup, only: [:new]
  def show
  end

  def fetch_plan
    # @stripe_list = Stripe::Plan.all
    # @plans = @stripe_list[:data]
    Stripe.api_key = 'sk_test_9yirvVjUk38CKrdRZcXI1wPw'
    @plan = Stripe::Plan.all
  end

  def payment_form
    #@payment = Payment.new
  end

  def new
  end

  def create
    Stripe.api_key = 'sk_test_9yirvVjUk38CKrdRZcXI1wPw'
    if params[:payment].present?
      plan_id =  params[:payment][:paln_id]
      plan = Stripe::Plan.retrieve(plan_id)
      token = params[:payment][:token]

      @payment = Payment.new({ email: current_user.email,
        token: params[:payment][:token], user_id: current_user.id })

      # product = Stripe::Product.retrieve(Rails.application.credentials.book_library)
      customer = if current_user.stripe_id?
                   Stripe::Customer.retrieve(current_user.stripe_id)
                 else
                   Stripe::Customer.create(email: current_user.email, source: token)
                 end
                 # binding.pry
      subscription = Stripe::Subscription.create({
                    customer: customer.id,
                    items: [{plan: plan.id}],
                  })

      @payment.process_payment(plan, customer)
      @payment.save

      user_plan = Plan.create(stripe_id: params[:payment][:paln_id],
        name: plan['nickname'], display_price: plan['amount'])
      Subscription.create(user_id: current_user.id,
        plan_id: user_plan.id)
      # subscription = customer.subscriptions.create(plan: plan.id)

      # options = {
      #   stripe_id: customer.id,
      #   stripe_subscription_id: subscription.id,
      #   subscribed: true,
      # }

      # options.merge!(
      #   card_last4: params[:user][:card_last4],
      #   card_exp_month: params[:user][:card_exp_month],
      #   card_exp_year: params[:user][:card_exp_year],
      #   card_type: params[:user][:card_type]
      # ) if params[:user][:card_last4]

      # current_user.update(options)

      redirect_to root_path, notice: " Your subscription was set up successfully!"
    end
  end

  def destroy
  end

  def send_job_mail
    # User.job_mail(current_user)
    # mail_job = {}
    # job_include = []
    # not_include_job = []
    # current_user.
    job_data = Job.where("content  ~* ? or content  ~* ? or content ~*  ?", current_user.include_job1, current_user.include_job2,
      current_user.include_job3)

    # mail_job = Job.where("content  ~* ?", "project manager")
    # mail_job.merge!(Job.where('content'.include? current_user.include_job2))
    # mail_job.merge!(Job.where('content'.include? current_user.include_job3))

    JobMailer.job_email(current_user, job_data).deliver_now
    flash[:alert] = "Email Sent Succesfully"
    redirect_to root_path
  end

  def subscription_dashboard

  end

  private

  def redirect_to_signup
    if !user_signed_in?
      session["user_return_to"] = new_subscription_path
      redirect_to new_user_registration_path
    end
  end
end
