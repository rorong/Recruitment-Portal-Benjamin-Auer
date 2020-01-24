require "stripe"
Rails.configuration.stripe = {
  :publishable_key => ENV['stripe_publishable_key'],
  :secret_key      => ENV['stripe_secret_key']
}

Stripe.api_key = ENV['stripe_secret_key']
