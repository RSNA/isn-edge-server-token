class ReportAuthor < ActiveRecord::Base
  set_primary_key :report_author_id
  belongs_to :report
end
