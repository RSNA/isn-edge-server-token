class EdgeConfiguration < ActiveRecord::Base
  set_table_name :configurations
  set_primary_key :configuration_id

  def before_save
    self.modified_date = Time.now
  end
end
