=begin rdoc
=Description
The HipaaMRN model is an active record representation
of the hipaa_audit_mrns table in the database.  It is
used by the HipaaFilter plugin.

It is primarly accessed through the HipaaView model.
=end
class HipaaMRN < ActiveRecord::Base
  set_table_name :hipaa_audit_mrns
end
