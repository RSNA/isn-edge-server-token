class JobTransaction < ActiveRecord::Base
  set_table_name :transactions
  set_primary_key :transaction_id
  belongs_to :job
end
