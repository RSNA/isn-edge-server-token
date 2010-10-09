class Patient < ActiveRecord::Base
  set_primary_key :patient_id
  has_many :reports, :through => :exams
  has_many :exams
  has_many :rsna_ids, :foreign_key => :patient_id

  def self.search(sstring)
    self.find(:all, :conditions => ["mrn ~* ? OR patient_name ~* ?", sstring, sstring])
  end

  def hl7_patient_name
    self.attributes['patient_name']
  end

  def patient_name
    self.attributes['patient_name'].split("^").join(", ")
  end

  def rsna_id
    @rsna_id ||= self.rsna_ids.first
  end

  def new_rsna_id(pin, confirmation_pin)
    @rsna_id = RsnaId.new(:pin => pin, :confirmation_pin => confirmation_pin, :rsna_id => "0001-#{self.padded_patient_id}-#{pin}", :patient_id => self.id, :patient_alias_firstname => "first", :patient_alias_lastname => "last", :modified_date => Time.now)
  end

  protected
  def padded_patient_id
    if 5 - self.id.to_s.size > 0
      "0"*(5-self.id.to_s.size) + self.id.to_s
    else
      self.id
    end
  end

end
