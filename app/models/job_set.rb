=begin rdoc
=Description
The JobSet model is an active record representation of the job_sets table in the database.
It uses active record to define association methods with the Job, and Patient models.
It also creates a convenience method for creating a job set using a patient_id and
a username.

This is also the class which generates the token to give to the patient and the single
use patient identifier.
=end
class JobSet < ActiveRecord::Base

  ZBASE32_ALPHABET = "ybndrfg8ejkmcpqxot1uwisza345h769"
  TOKEN_LENGTH = 8

  set_primary_key :job_set_id
  has_many :jobs, :dependent => :destroy
  belongs_to :patient
  belongs_to :user, :foreign_key => :user_id

  attr_accessor :patient_password, :patient_password_confirmation, :salt, :token

  validates_presence_of :patient_password


  # Checks the configurations table for a site_id
  # if not site_id is found it defaults to "0001" but does not memoize
  def self.site_id
    if @site_id
      @site_id
    else
      configured_site_id = EdgeConfiguration.find_by_key(:site_id)
      @site_id = configured_site_id.value if configured_site_id
      @site_id || "0001"
    end
  end

  # Checks to see if the confirmation password and password match before saving
  # to the database.
  def validate
    if self.patient_password != self.patient_password_confirmation
      errors.add(:patient_password, "and password confirmation do not match")
    end
  end

  # Creates a JobSet record using the patient_id and username supplied in the arguments
  def self.simple_create(patient_id, username)
    user = User.find_by_user_login(username)
    self.create({:patient_id => patient_id, :user_id => user.id})
  end

  protected
  # Triggers and returns the next value in the primary key sequence
  def self.next_id
    begin
      JobSet.find_by_sql("SELECT nextval('job_sets_job_set_id_seq') as value").first.value
    rescue
      raise "Failed to advance the job_sets_job_set_id_seq"
    end
  end

  # Call back method used to set the single use patient id
  def before_create
    self.id = self.class.next_id
    self.single_use_patient_id = trans_hash_gen()
  end

  # Generates the user token
  def user_token_gen(given_salt=ActiveSupport::SecureRandom.random_bytes(64))
    if @token
      @token
    else
      self.salt ||= given_salt
      hash = Digest::SHA256.hexdigest(JobSet.site_id.to_s + self.patient_id.to_s + self.id.to_s + self.salt).to_i(16)
      d = hash
      gen_token = ""
      for i in 0...TOKEN_LENGTH
        d,r = d.divmod(32)
        gen_token << ZBASE32_ALPHABET[r]
      end
      @token = gen_token
    end
  end

  # generates the transaction token
  def trans_hash_gen
    formatted_dob = self.patient.dob.strftime("%Y%m%d")
    hash = Digest::SHA256.hexdigest(self.user_token_gen + formatted_dob + self.patient_password)
  end
end
