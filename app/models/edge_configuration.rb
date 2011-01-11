=begin rdoc
=Description
The EdgeConfiguration model is an active record representation
of the configurstions table in the database.  The only changes
to the basic active record class is a callback function which
sets the modified date to the current timestamp whenever
the record is changes.
=end
class EdgeConfiguration < ActiveRecord::Base
  set_table_name :configurations
  set_primary_key :configuration_id

  def self.site_id
    self.find_by_key("site_id") || "0001"
  end

  def self.consent_duration
    self.find_by_key("consent_duration") || 365
  end

  # Call back function to set the modified date
  def before_save
    self.modified_date = Time.now
  end

end
