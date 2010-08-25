class Exam < ActiveRecord::Base
  set_primary_key :exam_id
  belongs_to :patient
  has_many :reports
  has_many :jobs

  def last_report
    Report.find(:first, :conditions => ["exam_id = ?", self.id], :order => "modified_date DESC")
  end

  def job
    Job.find(:first, :conditions => ["exam_id = ?", self.id], :order => "modified_date DESC")
  end
end
