=begin rdoc
=Description
The Device model is an active record representation of the
devices table in the database.  The only changes to the
basic active record class is presence validations for its
attributes (see source code) and a callback function which
sets the modified date to the current timestamp whenever
the record is changes.
=end
class Device < ActiveRecord::Base
  self.primary_key = "device_id"

  validates_presence_of :ae_title, :host, :port_number
  attr_accessible :ae_title, :host, :port_number

  # Call back function to set the modified date
  def before_save
    self.modified_date = Time.now
  end
end
