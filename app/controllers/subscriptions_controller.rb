class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :redirect_to_signup, only: [:new]
  before_action :stripe_api_key, only: [:create, :cancel_subscription]

  def create
    if current_user.present? && params[:plan_id].present?
      plan = Plan.find_by(plan_id: params[:plan_id])
      if params[:payment_method_id].present?
        response = current_user.create_subscription(params[:payment_method_id], plan, params[:package])
        error = response[0]
        success = response[1]
        if response[1]
          redirect_to user_dashboard_path, notice: "Subscription created successfully."
        else
          redirect_to user_dashboard_path, error: error.present? ? error : "Something went wrong!!!"
        end
      else
        redirect_to user_dashboard_path, notice: "Something went wrong!!!"
      end
    end
  end

  def cancel_subscription
    if current_user.stripe_id?
      begin
        subscription=current_user.subscription
        subs = Stripe::Subscription.retrieve(subscription.stripe_id)
        subs.delete
        subscription.destroy
        redirect_to user_dashboard_path, notice: " Your subscription deleted successfully!"       
      rescue Exception => e
        redirect_to user_dashboard_path, error: e.message
      end
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
