class Patient < ActiveRecord::Base
  set_primary_key :patient_id
  has_many :reports, :through => :exams
  has_many :exams
  has_many :rsna_ids, :foreign_key => :patient_id

  def self.search(*terms_for_search)
    with_scope(:find => {:joins => "LEFT JOIN patient_rsna_ids ON patient_rsna_ids.patient_id = patients.patient_id"}) do
      self.find(:all, :conditions => Search::Query.new(*terms_for_search).conditions)
    end
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
    @rsna_id = RsnaId.new(:security_pin => pin, :confirmation_pin => confirmation_pin, :rsna_id => "0001-#{self.padded_patient_id}", :patient_id => self.id, :patient_alias_firstname => "first", :patient_alias_lastname => "last", :modified_date => Time.now)
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
