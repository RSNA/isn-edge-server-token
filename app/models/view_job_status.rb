class ViewJobStatus < ActiveRecord::Base
  set_table_name :v_job_status
  belongs_to :job, :foreign_key => :job_id
  belongs_to :exam, :foreign_key => :exam_id

  # Filters using a basic search methodology on mrn, accession number, and patient name, single_user_patient_id.
  def self.filter(string)
    self.find(:all, {
                :joins => "LEFT JOIN (jobs JOIN exams ON (jobs.exam_id = exams.exam_id)) ON (jobs.job_id = v_job_status.job_id) LEFT JOIN (job_sets JOIN patients ON (patients.patient_id = job_sets.patient_id)) ON job_sets.job_set_id = jobs.job_set_id",
                :conditions => ["patients.mrn ~* ? OR patients.patient_name ~* ? OR exams.accession_number ~* ? OR job_sets.single_use_patient_id ~* ?", string, string, string, string],
                :order => "last_transaction_timestamp DESC",
                :limit => 100
            })
  end

end
