# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# plan = Stripe::Plan.create(
#   :amount => 10,
#   :interval => 'month',
#   :name => 'Basic Plan',
#   :currency => 'euro',
#   :id => 'basic'
# )

# Plan.create(name: plan.name, stripe_id: plan.id, display_price: (plan.amount.to_f / 100))

# Stripe::Plan.create(
#   :amount => 100,
#   :interval => 'year',
#   :name => 'Gold Plan',
#   :currency => 'euro',
#   :id => 'gold'
# )

# Plan.create(name: plan.name, stripe_id: plan.id, display_price: (plan.amount.to_f / 100))


# SecurityQuestion.create(question: "What is your place of birth?")
# SecurityQuestion.create(question: "What is your first school?")
# SecurityQuestion.create(question: "What is your mother's side maiden name?")

# Stripe.api_key = ENV['stripe_secret_key']

# product = Stripe::Product.create({
#             name: 'JobScrapperProduct',
#             type: 'service',
#           })

# Stripe::Plan.create({
#   amount: 200,
#   currency: 'usd',
#   interval: 'month',
#   nickname: 'monthly',
#   product: product.id,
# })

# Stripe::Plan.create({
#   amount: 500,
#   currency: 'usd',
#   interval: 'month',
#   interval_count: 3,
#   nickname: 'quaterly',
#   product: product.id,
# })

# Stripe::Plan.create({
#   amount: 1500,
#   currency: 'usd',
#   interval: 'month',
#   interval_count: 12,
#   nickname: 'yearly',
#   product: product.id,
# })


['monthly', 'quaterly', 'yearly'].each do|plan_name|
  case plan_name
    when 'monthly'
      amount = 1500
      interval="month"
      interval_count=1
    when 'quaterly'
      amount = 1000
      interval="month"
      interval_count=3
    when 'yearly'
      amount = 2000 
      interval="year"
      interval_count=1
  end

  begin
    plan = Stripe::Plan.create({
     amount: (amount*100),
     currency: 'usd',
     interval: interval,
     interval_count: interval_count,
     nickname: plan_name,
     product: 'prod_GnB5XQPvdtCnLd',
   }) 
    
    Plan.create(name: plan_name,
          display_price: amount,
          interval: interval,
          interval_count: interval_count,
          plan_id: plan.try(:id)
        )
  rescue Exception => e
    puts e.message
  end
end
 
Package.create(name: "Gold", plan_id: Plan.find_by(name:"monthly").id,interval:0)
Package.create(name: "Bronze", plan_id: Plan.find_by(name:"quaterly").id,interval: 1)
Package.create(name: "Silver", plan_id: Plan.find_by(name:"yearly").id,interval: 2)