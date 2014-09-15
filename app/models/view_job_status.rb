class ViewJobStatus < ActiveRecord::Base
  self.table_name = "v_job_status"
  self.primary_key = "job_set_id"
  belongs_to :job, :foreign_key => :job_id
  belongs_to :exam, :foreign_key => :exam_id

  # Filters using a basic search methodology on mrn, accession number, and patient name, single_user_patient_id.
  def self.filter(string)
    query = self.joins("LEFT JOIN (jobs JOIN exams ON (jobs.exam_id = exams.exam_id)) ON (jobs.job_id = v_job_status.job_id) LEFT JOIN (job_sets JOIN patients ON (patients.patient_id = job_sets.patient_id)) ON job_sets.job_set_id = jobs.job_set_id").order("last_transaction_timestamp DESC")
    query = query.where(*Search::Query.new(string).conditions()) unless string.blank?
    query
  end

end
