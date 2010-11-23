class Exam < ActiveRecord::Base
  set_primary_key :exam_id
  belongs_to :patient
  has_many :reports
  has_many :jobs

  named_scope :by_exam_description, lambda {|ed|
    query = Search::Query.new(ed)
    {:conditions => query.conditions(:exam_description => lambda { query.term_to_name_string(:exam_description) }) }
  }

  def last_report
    Report.find(:first, :conditions => ["exam_id = ?", self.id], :order => "modified_date DESC")
  end

  def job
    Job.find(:first, :conditions => ["exam_id = ?", self.id], :order => "modified_date DESC")
  end
end
