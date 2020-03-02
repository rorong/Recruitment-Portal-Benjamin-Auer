class TempJob < ApplicationRecord
  enum job_search_type: %i[derstandard karriere]
end
