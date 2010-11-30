=begin rdoc
=Description
The HipaaView model is an active record representation
of the hipaa_audit_views table in the database.  It is
used by the HipaaFilter plugin.

This model generates and links to the HipaaAccessionNumber
and HipaaMRN models.
=end
class HipaaView < ActiveRecord::Base
  set_table_name :hipaa_audit_views
  has_many :hipaa_accession_numbers
  has_many :hipaa_mrns

  # Create a record in the database with the given hash as the attribute mappings.
  # Create the HipaaMRN and HipaaAccessionNumber records associated with the view
  # and link them with the primary key generated for the HippaView
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

  # Used to prevent views without phi associated from trying to create records
  # in the HipaaAccessionNumber and HipaaMRN tables
  def self.create_phi_items(list, &block)
    if list
      list.collect(&block)
    end
  end
end
