class SecurityQuestion < ApplicationRecord
  belongs_to :user, optional: true
  has_one :answer
  validates :question, presence: true
end
