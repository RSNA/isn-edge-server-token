=begin rdoc
=Description
The Report model is an active record representation of the reports table in the database.
It uses active record to define association methods with the ReportAuthor, Exam, and
Patient models.
=end
class Report < ActiveRecord::Base
  self.primary_key = "report_id"
  has_one :report_author
  belongs_to :exam
  belongs_to :patient

end
