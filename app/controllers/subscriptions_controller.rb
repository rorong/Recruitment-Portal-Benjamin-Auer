class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stripe_api_key, only: [:create, :cancel_subscription]

  def create
    if params[:plan_id].present? && params[:payment_method_id].present?
      plan = Plan.find_by(plan_id: params[:plan_id])
      response = current_user.create_subscription(params[:payment_method_id], plan, params[:package])
      error = response[0]
      success = response[1]
      if response[1]
        redirect_to user_dashboard_path, notice: "Subscription created successfully!"
      else
        redirect_to user_dashboard_path, error: error.present? ? error : "Something went wrong please try later!!!"
      end
    else
      redirect_to user_dashboard_path, error: "Something went wrong please try later!!!"
    end
  end

  def cancel_subscription
    response = current_user.cancel_subscription
    error = response[0]
    success = response[1]
    if error
      redirect_to user_dashboard_path, error: error
    else
      redirect_to user_dashboard_path, notice: "Your subscription has been cancelled successfully."
    end
  end

  private

  def set_stripe_api_key
    Stripe.api_key = ENV['stripe_secret_key']
  end
end
