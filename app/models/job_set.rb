=begin rdoc
=Description
The JobSet model is an active record representation of the job_sets table in the database.
It uses active record to define association methods with the Job, and Patient models.
It also creates a convenience method for creating a job set using a patient_id and
a username.
=end
class JobSet < ActiveRecord::Base
  set_primary_key :job_set_id
  has_many :jobs, :dependent => :destroy
  belongs_to :patient

  # Creates a JobSet record using the patient_id and username supplied in the arguments
  def self.simple_create(patient_id, username)
    user = User.find_by_user_login(username)
    self.create({:patient_id => patient_id, :user_id => user.id})
  end
end
