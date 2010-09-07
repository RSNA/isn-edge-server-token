class AdminController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart
  hipaa_filter

  def audit
    @job_sets = JobSet.find(:all, :limit => 30, :order => "modified_date DESC")
  end
end
