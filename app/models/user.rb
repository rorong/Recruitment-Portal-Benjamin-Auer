class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :create_job_search

  has_one :job_search, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one  :plan, through: :subscription
  has_one :payment
  belongs_to :admin, optional: true
  has_one :package , through: :subscription
  has_many :jobs, dependent: :destroy

  def password_required?
    false
  end

  def self.job_mail user
    JobMailer.job_email(user)
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  def create_job_search
    JobSearch.create(user_id: self.id, designation: 'project manager', location: 'wien')
  end

  def create_subscription(payment_method_id, plan, package)
    error = nil
    success = nil
    begin
      customer =  if self.stripe_id?
                    Stripe::Customer.retrieve(self.stripe_id)
                  else
                    Stripe::Customer.create({
                      payment_method: payment_method_id,
                      email: self.email,
                      name: self.first_name,
                      address: {
                                  city: "Delhi",
                                  country: "United States",
                                  line1: "asdaad",
                                  line2: "nll",
                                  postal_code: "10001",
                                  state: "U.S"
                            },
                      invoice_settings: {
                        default_payment_method: payment_method_id,
                      },
                    })
                  end
      subscription =  Stripe::Subscription.create({
                        customer: customer.id,
                        items: [{plan: plan.plan_id}],
                      }) if customer.present?

      Subscription.create(stripe_id: subscription.id,
                          user_id: self.id,
                          plan_id: plan.id,
                          package_id: package
                        ) if subscription.present?
      self.update_column(:stripe_id, customer.id)
      success = true if customer.present? && self.subscription.present? && self.subscription.stripe_id.present?
    rescue Exception => e
      error = e.message
    end
    return error, success
  end

  def cancel_subscription
    error = nil
    success = nil    
    begin
      stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_id)
      response = stripe_subscription.delete
      if response.present? && response.status.eql?('canceled')
        subscription.destroy
        success = true
      end
    rescue Exception => e
      error = e.message
    end
    return error, success 
  end

end
