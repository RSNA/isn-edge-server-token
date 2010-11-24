class Device < ActiveRecord::Base
  set_primary_key :device_id

  validates_presence_of :ae_title, :host, :port_number

  def before_save
    self.modified_date = Time.now
  end
end
