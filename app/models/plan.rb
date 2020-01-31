class Plan < ApplicationRecord
  has_one :subscription
  belongs_to :admin, optional: true
end
