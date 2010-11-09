class RsnaId < ActiveRecord::Base
  set_table_name :patient_rsna_ids
  set_primary_key :map_id

  attr_accessor :pin, :confirmation_pin

  belongs_to :patient, :foreign_key => :patient_id

  def validate
    if self.pin and self.pin.size != 6
      errors.add(:pin, "must be 6 characters long")
    end
    if self.pin != self.confirmation_pin
      errors.add(:pin, "and confirmation pin do not match")
    end
  end
end
