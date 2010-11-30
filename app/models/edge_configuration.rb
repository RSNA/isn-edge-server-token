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

  # Call back function to set the modified date
  def before_save
    self.modified_date = Time.now
  end
end
