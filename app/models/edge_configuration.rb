=begin rdoc
=Description
The EdgeConfiguration model is an active record representation
of the configurstions table in the database.  The only changes
to the basic active record class is a callback function which
sets the modified date to the current timestamp whenever
the record is changes.
=end
class EdgeConfiguration < ActiveRecord::Base

  # Call back function to set the modified date
  attr_accessible :key, :value, :given_key
  before_validation :fix_keys

  def fix_keys
    self.key = self.given_key
    self.modified_date = Time.now
  end

  self.table_name = "configurations"
  self.primary_key = "key"

  attr_accessor :given_key
  validates_uniqueness_of :key
  validates_presence_of :key

  def self.site_id
    sid = self.find_by_key("site_id")
    if sid
      sid.value
    else
      "0001"
    end
  end

  def self.help_desk_message
    hdm = self.find_by_key("help_desk_message")
    if hdm
      hdm.value
    else
      "If you encounter any problems or have questions contact the Image Sharing Help Desk:<br />
                    Email: helpdesk@imsharing.org<br />
                    Toll-free number: 1-855-IM-SHARING (467-4274)<br />
                    Hours: 8am-8pm Eastern Time, Monday through Friday (except holidays)"
      #"Please contact helpdesk@imsharing.org or call 1-855-IM-SHARING (467-4274) for support"
    end
  end

  def self.ctp_protocol
    ctpp = self.find_by_key("ctp_protocol")
    if ctpp
      ctpp.value
    else
      "http"
    end
  end

  def self.ctp_port
    ctpp = self.find_by_key("ctp_port")
    if ctpp
      ctpp.value
    else
      "1080"
    end
  end

  def self.consent_duration
    consent_duration = self.find_by_key("consent_duration")
    if consent_duration
      consent_duration.value.to_i
    else
      365
    end
  end

  def self.assume_last_name_first
    ec = self.find_by_key("assume_last_name_first")
    if ec
      ec.value.downcase == "true"
    else
      false
    end
  end


end
