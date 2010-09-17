class Job < ActiveRecord::Base
  set_primary_key :job_id
  belongs_to :job_set
  belongs_to :exam
  has_many :job_transactions, :dependent => :destroy

  def last_transaction
    @last_transaction ||= self.job_transactions.find(:first, :order => "modified_date DESC")
  end

  def status_message
    self.last_transaction.status_message if self.last_transaction
  end
end
