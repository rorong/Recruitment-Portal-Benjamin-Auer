class JobSearch < ApplicationRecord
  belongs_to :user, optional: true
  validates :designation, :location, presence: true
end
