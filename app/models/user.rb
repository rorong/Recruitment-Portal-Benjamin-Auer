class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :security_questions
  has_one :subscription, dependent: :destroy
  has_one  :plan, through: :subscription

  has_one :payment

  def password_required?
    false
  end

  def self.job_mail user
    JobMailer.job_email(user)
  end
end
