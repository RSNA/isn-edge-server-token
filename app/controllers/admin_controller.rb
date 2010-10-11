class AdminController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart
  hipaa_filter

  def audit
    @job_transactions = JobTransaction.find(:all, :limit => 100, :order => "modified_date DESC")
  end

  def audit_details
    @jt = JobTransaction.find(params[:id])
    render({:partial => "admin/audit_details",
      :locals => {:patient => @jt.job.job_set.patient, :job_set => @jt.job.job_set}
    })
  end

  def audit_filter
    @job_transactions = JobTransaction.filter(params[:filter])
    render(:partial => "admin/transaction_list", :locals => {:job_transactions => @job_transactions})
  end
end
