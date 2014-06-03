=begin rdoc
=Description
The Job model is an active record representation of the jobs table in the database.
It uses active record to define association methods with the JobSet, Exam, and
JobTransaction models.  It also creates convience methods for pulling the latest
job status and transaction record.

=Named Scopes
*ordered*() - Orderes the sql by the modified_date DESC
=end
class Job < ActiveRecord::Base
  self.primary_key = "job_id"
  belongs_to :job_set
  belongs_to :exam
  has_many :job_transactions, :dependent => :destroy

  attr_accessible :exam_id, :job_set_id, :modified_date

  scope :ordered, -> { order("modified_date DESC") }

  before_create do
    self.remaining_retries = EdgeConfiguration.find_by_key("max-retries").value unless self.remaining_retries
  end

  # Finds the most recent JobTransaction associated with this Job
  def last_transaction
    @last_transaction ||= self.job_transactions.order("modified_date DESC").first
  end

  # Finds the most recent status message associated with this Job
  def status_message
    self.last_transaction.status_message if self.last_transaction
  end
end
