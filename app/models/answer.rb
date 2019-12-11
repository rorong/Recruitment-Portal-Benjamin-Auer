class Answer < ApplicationRecord
  belongs_to :security_question
  validates :answer, presence: true
end
