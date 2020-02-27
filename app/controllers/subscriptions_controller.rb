class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :redirect_to_signup, only: [:new]
  before_action :fetch_plan, only: [:payment_form]
  before_action :stripe_api_key, only: [:create, :cancel_subscription]

  def fetch_plan
    
    @plan = Stripe::Plan.all
  end

  def create
    
    if current_user.present? && params[:plan_id].present?
      plan = Plan.find_by(plan_id: params[:plan_id])
      if params[:payment_method_id].present?
        #move it to a model instance method
        customer =  if current_user.stripe_id?
                      Stripe::Customer.retrieve(current_user.stripe_id)
                    else
                      Stripe::Customer.create({
                        payment_method: params[:payment_method_id],
                        email: current_user.email,
                        name: current_user.first_name,
                         address: {
                                      city: "Delhi",
                                      country: "United States",
                                      line1: "asdaad",
                                      line2: "nll",
                                      postal_code: "10001",
                                      state: "U.S"
                                    },
                        invoice_settings: {
                          default_payment_method: params[:payment_method_id],
                        },
                      })
                    end
        subscription =  Stripe::Subscription.create({
                          customer: customer.id,
                          items: [{plan: plan.plan_id}],
                        }) if customer.present?

        Subscription.create(stripe_id: subscription.id,
                            user_id: current_user.id,
                            plan_id: plan.id,
                            package_id: params[:package]
                            )

        current_user.update_attributes(stripe_id: customer.id)

        redirect_to user_dashboard_path, notice: "Your subscription was set up successfully!"
      else
        redirect_to user_dashboard_path, notice: "Something went wrong!!!"
      end
    end
  end

  def cancel_subscription
    
    if current_user.stripe_id?
      subscription=current_user.subscription
      subs = Stripe::Subscription.retrieve(subscription.stripe_id)
      subs.delete
      subscription.destroy
      #Sidekiq.remove_schedule(current_user.email)
      # current_user.update(package: 0, stripe_subscription_id: nil)
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

  def stripe_api_key
    Stripe.api_key = ENV['stripe_secret_key']
  end
end
