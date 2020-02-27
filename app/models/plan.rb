class Plan < ApplicationRecord
  has_many :subscriptions
  has_many :users, through: :subscriptions
  belongs_to :admin, optional: true
  has_one :package
end
