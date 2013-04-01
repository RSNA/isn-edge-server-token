=begin rdoc
=Description
Handling of adding and deleting exams from the cart and the creation of jobs when sending the cart.
=end
class ExamsController < ApplicationController
  before_filter :authenticate
  before_filter :get_cart
  before_filter :force_patient, :except=>[:retry_job]
  hipaa_filter

  # List the exams for the specified patient
  def index
    @exams = @patient.exams
    @autoprint_rsna_id = ((params[:token] or not params[:email_address].blank?) ? true : false)
  end

  def print_patient_info
    @token = params[:token]
    @email_address = params[:email_address]
    render :layout => "layouts/print", :template => "exams/print_patient_info"
  end

  # Filter the patients exams by the exam description
  def filter
    @exams = @patient.exams.by_exam_description(params[:filter])
    render :partial => "exams/results", :locals => {:exams => @exams, :patient => @patient}
  end

  # Given the cart, create the job set, jobs and transaction entries
  def send_cart
    delay_in_hrs = params[:override_delay] == '1' ? 0 : JobSet.delay_in_hrs;
    @job_set = JobSet.new({
                            :patient_id => @patient.id,
                            :user_id => @user.id,
                            :patient_password => params[:patient_password],
                            :patient_password_confirmation => params[:patient_password_confirmation],
                            :email_address => params[:email],
                            :modified_date => Time.now,
                            :delay_in_hrs => delay_in_hrs
                          })
    if @job_set.save
      @cart.each do |exam_id|
        time = Time.now
        job = Job.create(:exam_id => exam_id, :job_set_id => @job_set.id, :modified_date => time)
        JobTransaction.create(:job_id => job.id, :status_code => 1, :comments => "Queued", :modified_date => time)
      end
      cart_op {|cart| [] }
      flash[:notice] = "Exams queued and patient information printed"
      render :partial => "exams/token_info"
    else
      render :text => "An error occured while saving your cart information"
    end
  end

  def validate_cart
    @job_set = JobSet.new({:patient_password => params[:patient_password], :patient_password_confirmation => params[:patient_password_confirmation]})
    if @job_set.valid?
      render :json => true
    else
      render :json => @job_set.errors
    end
  end

  # Show the cart
  def show_cart
    @exams = @cart.collect {|id| Exam.find(id) }
  end

  # Add an exam to the cart
  def add_to_cart
    cart_op {|cart| cart << params[:id].to_i } if not params[:id].blank? and not get_cart.find {|i| i == params[:id].to_i }
    render_cart_size
  end

  # Remove an exam from the cart
  def delete_from_cart
    cart_op {|cart| cart.delete(params[:id].to_i); cart }
    render_cart_size
  end

  # Empty the cart
  def empty_cart
    cart_op {|cart| [] }
    flash[:notice] = "Emptied Shopping Cart"
    redirect_to :action => :index
  end

  # Create new transaction to retry failed job
  def retry_job
    JobTransaction.create(:job_id => params[:id], :status_code => 1, :comments => "Retry", :modified_date => Time.now)
  end

end
