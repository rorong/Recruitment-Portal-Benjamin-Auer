class Answer < ApplicationRecord
  belongs_to :security_question, optional: true
  validates :answer, presence: true
end
