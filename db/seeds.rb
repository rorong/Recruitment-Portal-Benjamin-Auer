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


SecurityQuestion.create(question: "What is your place of birth?")
SecurityQuestion.create(question: "What is your first school?")
SecurityQuestion.create(question: "What is your mother's side maiden name?")
