class Patient < ActiveRecord::Base
  set_primary_key :patient_id
  has_many :reports, :through => :exams
  has_many :exams
  has_many :rsna_ids, :foreign_key => :patient_id

  def self.search(sstring)
    self.find(:all, :conditions => ["mrn ~* ? OR patient_name ~* ?", sstring, sstring])
  end

  def rsna_id
    @rsna_id ||= self.rsna_ids.first
  end

  def new_rsna_id(pin)
    @rsna_id = RsnaId.new(:pin => pin, :rsna_id => "1-#{self.id}-#{pin}", :patient_id => self.id, :modified_date => Time.now)
  end

end
