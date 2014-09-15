=begin rdoc
=Description
The EmailConfiguration model is an active record representation
of the configurstions table in the database.  The only changes
to the basic active record class is a callback function which
sets the modified date to the current timestamp whenever
the record is changes.
=end
class EmailConfiguration < ActiveRecord::Base

  # Call back function to set the modified date
  attr_accessible :key, :value, :given_key
  before_validation :fix_keys

  def fix_keys
    self.key = self.given_key
    self.modified_date = Time.now
  end

  self.table_name = "email_configurations"
  self.primary_key = "key"

  attr_accessor :given_key
  validates_uniqueness_of :key
  validates_presence_of :key

  def self.update_or_insert(k,v)
    Rails.logger.debug("Email configuraiton: #{k} : #{v}")
    ec = self.where(key: k).first
    if ec
      ec.given_key = k
      ec.value = v
      ec.save
    else
      self.create(given_key: k, value: v)
    end
  end

  def self.value_for(key)
    ec = self.find_by_key(key)
    if ec
      ec.value
    else
      nil
    end
  end

end
