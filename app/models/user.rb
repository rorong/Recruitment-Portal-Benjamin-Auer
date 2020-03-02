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

end
