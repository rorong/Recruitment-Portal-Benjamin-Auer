class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #has_one :security_question, dependent: :destroy
  has_one :job_search , dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one  :plan, through: :subscription
  #has_many :jobs , dependent: :destroy
  has_one :payment
  belongs_to :admin, optional: true
  
  enum package: { "no email package":0 , 
                  "Receive emails daily":1 ,
                  "Receive email once a week":2 , 
                  "Receive email once every two weeks":3}

  #validates :first_name, :last_name, presence: true

  def password_required?
    false
  end

  def self.job_mail user
    JobMailer.job_email(user)
  end

  def fullname
    "#{first_name} #{last_name}"
  end

end
