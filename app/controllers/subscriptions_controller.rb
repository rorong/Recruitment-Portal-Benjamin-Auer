class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :redirect_to_signup, only: [:new]
  before_action :fetch_plan, only: [:payment_form]

  def fetch_plan
    Stripe.api_key = ENV['stripe_secret_key']
    @plan = Stripe::Plan.all
  end

  def create
    if current_user.present? && params[:plan_id].present?
      plan_id =  params[:plan_id]
      plan = Stripe::Plan.retrieve(plan_id)

      if params[:payment_method_id].present?
        #payment = Payment.create(email: current_user.email, user_id: current_user.id)

        #@payment = Payment.new({ email: current_user.email, user_id: current_user.id })

        customer =  if current_user.stripe_id?
                      Stripe::Customer.retrieve(current_user.stripe_id)
                    else
                      Stripe::Customer.create({
                        payment_method: params[:payment_method_id],
                        email: current_user.email,
                        invoice_settings: {
                          default_payment_method: params[:payment_method_id],
                        },
                      })
                    end

        subscription =  Stripe::Subscription.create({
                          customer: customer.id,
                          items: [{plan: plan.id}],
                        }) if customer.present?

        #@payment.process_payment(plan, customer)
        #@payment.save

        user_plan = Plan.create(stripe_id: params[:plan_id],
          name: plan['nickname'], display_price: plan['amount'])

        Subscription.create(user_id: current_user.id,
          plan_id: user_plan.id)

        current_user.update_attributes(stripe_id: customer.id, stripe_subscription_id: subscription.id) if customer.present? && subscription.present?

        redirect_to user_dashboard_path, notice: "Your subscription was set up successfully!"
      else
        redirect_to user_dashboard_path, notice: "Something went wrong!!!"
      end
    end
  end

  def send_job_mail
    include_job = current_user.include_job1? || current_user.include_job2? || current_user.include_job3?

    not_include_job = current_user.not_include_job1? || current_user.not_include_job2? || current_user.not_include_job3?

    if include_job || not_include_job
      job_data = Job.where("title = ? OR title = ? OR title = ?", current_user.include_job1, current_user.include_job2, current_user.include_job3).where.not("title = ? OR title = ? OR title = ?", current_user.not_include_job1, current_user.not_include_job2, current_user.not_include_job3)
    else
      job_data = Job.all
    end

    JobMailer.job_email(current_user, job_data).deliver_now if job_data.present?

    if job_data.present?
      redirect_to user_dashboard_path, notice: "Email Sent Succesfully!!!"
    else
      redirect_to user_dashboard_path, notice: "No job found!!!"
    end
  end

  def cancel_subscription
    Stripe.api_key = ENV['stripe_secret_key']
    if current_user.stripe_id? && current_user.stripe_subscription_id?
      customer = Stripe::Customer.retrieve(current_user.stripe_id)

      stripe_subscription = customer.subscriptions.retrieve(current_user.stripe_subscription_id) if customer.present?
      stripe_subscription.delete

      subscription = current_user.subscription
      subscription.destroy if subscription.present?

      current_user.update_attributes(stripe_subscription_id: nil, stripe_id: nil)
      redirect_to user_dashboard_path, notice: " Your subscription deleted successfully!"
    else
      redirect_to user_dashboard_path, notice: "Something went wrong!!!"
    end
  end

  private

  def redirect_to_signup
    if !user_signed_in?
      session["user_return_to"] = new_subscription_path
      redirect_to new_user_registration_path
    end
  end
end
