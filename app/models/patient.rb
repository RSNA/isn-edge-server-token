=begin rdoc
=Description
The Patient model is an active record representation
of the patients table in the database.

It uses active record to define association methods between
itself and the Report, Exam, and RsnaId models.
=end
class Patient < ActiveRecord::Base
  self.primary_key = "patient_id"
  has_many :reports, :through => :exams
  has_many :exams
  has_many :job_sets

  # This builds a search query using the Search model and a with_scope that joins the RsnaId model
  # terms_for_search can be a string or a hash of field value pairs, e.g:
  #
  #   Patient.search("John Doe")
  #   Patient.search(:mrn => "0982734", :rsna_id => "9823", :patient_name => "Doe, John")
  def self.search(*terms_for_search)
    self.unscoped.where(Search::Query.new(*terms_for_search).conditions)
  end

  # Accessor for getting the exact value of patient_name in the database.  This usually contains
  # an HL7 version of the name, i.e., Doe^John^^ hence the name of the method.
  def hl7_patient_name
    self.attributes['patient_name']
  end

  # This takes the raw value of the patient name in the database and formats it with commas instead of carrots
  def patient_name
    self.attributes['patient_name'].split("^").join(", ")
  end

  def rsna_id_email
    @rsna_id_email_record = JobSet.where("patient_id = ? AND email_address IS NOT NULL",self.id).order("job_set_id desc").first
    @rsna_id_email_record.email_address if @rsna_id_email_record
  end

  def consented?
    if self.consent_timestamp and ((Time.now - self.consent_timestamp) / 86400) <= EdgeConfiguration.consent_duration
      true
    else
      false
    end
  end

  protected
  # Pads the patient id supplied by the hl7 with the required number of zeros so that the RsnaId
  # matches the formatting spec supplied
  def padded_patient_id
    if 5 - self.id.to_s.size > 0
      "0"*(5-self.id.to_s.size) + self.id.to_s
    else
      self.id
    end
  end

end
