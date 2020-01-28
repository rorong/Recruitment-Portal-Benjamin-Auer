module RegistrationsHelper

  def get_plan_detail
     plan_stripe_id = current_user.subscription.try(:plan).try(:stripe_id)
     Stripe.api_key = ENV['stripe_secret_key']
     plan = Stripe::Plan.retrieve(plan_stripe_id)
  end

  def list_all_plan
    Stripe.api_key = ENV['stripe_secret_key']
    @plan = Stripe::Plan.all
  end
end
