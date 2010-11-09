class RsnaId < ActiveRecord::Base
  set_table_name :patient_rsna_ids
  set_primary_key :map_id

  attr_accessor :confirmation_pin

  belongs_to :patient, :foreign_key => :patient_id

  def validate
    if self.security_pin and self.security_pin.size != 6
      errors.add(:pin, "must be 6 characters long")
    end
    if self.security_pin != self.confirmation_pin
      errors.add(:pin, "and confirmation pin do not match")
    end
  end

  def self.fix_pin_location(rsna_ids)
    rsna_ids.each do |rsna_id|
      list = rsna_id.rsna_id.split("-")
      if list.size == 3
        pin = list.pop
        rsna_id.update_attributes(:confirmation_pin => pin, :security_pin => pin, :rsna_id => list.join("-"))
      end
    end
  end
end
