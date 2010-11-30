=begin rdoc
=Description
The ReportAuthor model is an active record representation of the report_authors table
in the database. It uses active record to define association methods with the Report
model.
=end
class ReportAuthor < ActiveRecord::Base
  set_primary_key :report_author_id
  belongs_to :report
end
