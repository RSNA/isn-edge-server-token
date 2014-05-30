=begin rdoc
=Description
The RsnaId model is an active record representation of the patiens_rsna_ids
table in the database. It uses active record to define association methods
with the Patient model.

A validate callback is also defined to confirm the entered pin information matches.
=end
class RsnaId < ActiveRecord::Base
  self.table_name = "patient_rsna_ids"
  self.primary_key = "map_id"

  attr_accessor :pin, :confirmation_pin

  belongs_to :patient, :foreign_key => :patient_id

  # Checks to see if the confirmation pin and pin match before saving
  # to the database.
  def validate
    if self.pin and self.pin.size != 6
      errors.add(:pin, "must be 6 characters long")
    end
    if self.pin != self.confirmation_pin
      errors.add(:pin, "and confirmation pin do not match")
    end
  end
end
