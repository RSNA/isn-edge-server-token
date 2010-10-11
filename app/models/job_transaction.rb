class JobTransaction < ActiveRecord::Base
  set_table_name :transactions
  set_primary_key :transaction_id
  belongs_to :job

  def self.filter(string)
    self.find(:all, {
                :joins => "LEFT JOIN (jobs JOIN exams ON (jobs.exam_id = exams.exam_id)) ON (jobs.job_id = transactions.job_id) LEFT JOIN (job_sets JOIN patients ON (patients.patient_id = job_sets.patient_id)) ON job_sets.job_set_id = jobs.job_set_id",
                :conditions => ["patients.mrn ~* ? OR patients.patient_name ~* ? OR exams.accession_number ~* ?", string, string, string],
                :order => "transactions.modified_date DESC",
                :limit => 100
            })
  end
end
