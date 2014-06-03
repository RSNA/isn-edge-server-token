=begin rdoc
=Description
The Exam model is an active record representation
of the exams table in the database.

It uses active record to define association methods between
itself and the reports, jobs, and patients models. It defines
convenience methods for getting the most recent values of the
jobs and reports associations.

==Named Scopes
*by_exam_description*(_description_) - takes and exam description
and queries the exams table filtering by that field.  This uses
the Search module to generate permutations of the exam description

=end
class Exam < ActiveRecord::Base
  self.primary_key = "exam_id"
  belongs_to :patient
  has_many :reports
  has_many :jobs

  def self.filter_cancelled(exams)
    exams.to_ary.delete_if {|e| e.last_report and e.last_report.status == "CANCELED" }
  end

  scope :by_exam_description, lambda {|ed|
    query = Search::Query.new(ed)
    conds = query.conditions(:exam_description => lambda { query.term_to_name_string(:exam_description) })
    where(*conds)
  }

  def latest_information
    @latest_information ||= ViewExamStatus.where("exam_id = ?",self.id).take
  end

  # Gets the most recent report associated with this exam
  def last_report
    if self.latest_information and self.latest_information.report_id
      @last_report ||= Report.find(self.latest_information.report_id)
    else
      nil
    end
  end

  # Gets the most recent job associated with this exam
  def job
    @job ||= Job.where("exam_id = ?", self.id).order("modified_date DESC").first
  end

  def job_transaction
    @job_transaction ||= JobTransaction.where("job_id = ?", self.job.id).order("modified_date DESC").first if self.job
  end
end
