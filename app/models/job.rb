class Job < ApplicationRecord
  belongs_to :user
  enum job_search_type: %i[derstandard karriere]
end
