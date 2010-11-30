=begin rdoc
The JobTransaction model is an active record representation of the transactions view
in the database. It uses active record to define association methods with the Job model.
=end
class JobTransaction < ActiveRecord::Base
  set_table_name :transactions
  set_primary_key :transaction_id
  belongs_to :job

  # Filters using a basic search methodology on mrn, accession number, and patient name.
  # This will be switched to use the Search::Query builder in the future.
  def self.filter(string)
    self.find(:all, {
                :joins => "LEFT JOIN (jobs JOIN exams ON (jobs.exam_id = exams.exam_id)) ON (jobs.job_id = transactions.job_id) LEFT JOIN (job_sets JOIN patients ON (patients.patient_id = job_sets.patient_id)) ON job_sets.job_set_id = jobs.job_set_id",
                :conditions => ["patients.mrn ~* ? OR patients.patient_name ~* ? OR exams.accession_number ~* ?", string, string, string],
                :order => "transactions.modified_date DESC",
                :limit => 100
            })
  end
end
