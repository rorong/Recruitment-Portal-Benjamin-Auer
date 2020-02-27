class Package < ApplicationRecord
	belongs_to :plan
	has_many :subscriptions
	has_many :users, through: :subscriptions
	enum interval: { "Daily":0,
					 "Weekly": 1,
					 "Every 2 Weeks": 2,
					 "Monthly":3,
					 "Yearly":4
					}
end
