class Report < ActiveRecord::Base
  set_primary_key :report_id
  has_one :report_author
  belongs_to :exam
  belongs_to :patient

end
