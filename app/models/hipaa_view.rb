class HipaaView < ActiveRecord::Base
  set_table_name :hipaa_audit_views
  has_many :hipaa_accession_numbers
  has_many :hipaa_mrns

  def self.create_event(hipaa_filter_hash)
    view = self.new({
                      :requesting_username => hipaa_filter_hash[:requesting_username],
                      :requesting_ip => hipaa_filter_hash[:requesting_ip],
                      :requesting_uri => hipaa_filter_hash[:request_uri],
                      :modified_date => hipaa_filter_hash[:created_at]
                    })
    if view.save
      self.create_phi_items(hipaa_filter_hash[:accession_number]) {|acc_num| HipaaAccessionNumber.create(:view_id => view.id, :accession_number => acc_num) }
      self.create_phi_items(hipaa_filter_hash[:patient_id]) {|pat_id| HipaaMRN.create(:view_id => view.id, :mrn => pat_id) }
      view
    else
      false
    end
  end

  def self.create_phi_items(list, &block)
    if list
      list.collect(&block)
    end
  end
end
