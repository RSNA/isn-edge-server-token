class JobSet < ActiveRecord::Base
  set_primary_key :job_set_id
  has_many :jobs, :dependent => :destroy
  belongs_to :patient

  def self.simple_create(patient_id, username)
    user = User.find_by_user_login(username)
    self.create({:patient_id => patient_id, :user_id => user.id})
  end
end
