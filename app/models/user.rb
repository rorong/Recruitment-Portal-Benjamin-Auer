class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :security_questions
  has_one :job_search, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one  :plan, through: :subscription

  has_one :payment
  belongs_to :admin, optional: true
  has_many :jobs, dependent: :destroy


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
