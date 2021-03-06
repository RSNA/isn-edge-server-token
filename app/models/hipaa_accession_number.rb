=begin rdoc
=Description
The HipaaAccessionNumber model is an active record
representation of the hipaa_audit_accesssion_number table
in the database.  It is used by the HipaaFilter plugin.

It is primarly accessed through the HipaaView model.
=end
class HipaaAccessionNumber < ActiveRecord::Base
  self.table_name = "hipaa_audit_accession_numbers"

  attr_accessible :view_id, :accession_number
end
