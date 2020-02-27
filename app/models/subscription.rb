class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :package , optional: true
end
