module RegistrationsHelper

  def get_plan_detail(user)
  	begin
	    plan_stripe_id = user.subscription.try(:plan).try(:stripe_id)
	    Stripe.api_key = ENV['stripe_secret_key']
	    plan = Stripe::Plan.retrieve(plan_stripe_id)  		
  	rescue Exception => e
  		plan = nil
  	end
  end

  def list_all_plan
  	begin
      Stripe.api_key = ENV['stripe_secret_key']
      all_stripe_plans = Stripe::Plan.all
      plans = plans.data if all_stripe_plans.present? 		
  	rescue Exception => e
  		plans = []
  	end
  end
end
