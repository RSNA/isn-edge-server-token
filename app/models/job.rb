class Job < ActiveRecord::Base
  set_primary_key :job_id
  belongs_to :job_set
  belongs_to :exam
end
