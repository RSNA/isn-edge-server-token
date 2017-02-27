=begin rdoc
=Description
Handling of adding and deleting exams from the cart and the creation of jobs when sending the cart.
=end
class ExamsController < ApplicationController
  before_filter :authenticate
  before_filter :get_cart
  before_filter :force_patient, :except => [:retry_job]
  hipaa_filter

  # List the exams for the specified patient
  def index
    @exams = Exam.filter_cancelled(@patient.exams)
    @autoprint_rsna_id = (["send_to_site", "rsna_id", "standard"].include?(params[:logic_type]) ? true : false)
    @send_components = {:email_address => params[:email_address], :token => params[:token], :formatted_dob => params[:formatted_dob], :access_code => params[:access_code], :logic_type => params[:logic_type]}
  end

  def print_patient_info
    @token = params[:token]
    @email_address = params[:email_address]
    @logic_type = params[:logic_type]
    if @logic_type != "send_to_site"
      render :layout => "layouts/print", :template => "exams/print_patient_info"
    else
      render :layout => "layouts/print", :template => "exams/print_site_to_site_info"
    end
  end

  # Filter the patients exams by the exam description
  def filter
    @exams = @patient.exams
    @exams = @exams.by_exam_description(params[:filter]) unless params[:filter].blank?
    Exam.filter_cancelled(@exams) unless params[:show_cancelled].blank?
    render :partial => "exams/results", :locals => {:exams => @exams, :patient => @patient}
  end

  # Given the cart, create the job set, jobs and transaction entries
  def send_cart
    case params[:override_delay]
    when '1'
      delay_in_hrs = 0
    when '2'
      delay_in_hrs = 0
      send_on_complete = true
    else
      delay_in_hrs = JobSet.delay_in_hrs;
    end
    send_on_complete ||= false

    if params[:autosend] and !@patient.autosend
      @patient.autosend = true
      @patient.save
    elsif params[:autosend].nil? and @patient.autosend
      @patient.autosend = false
      @patient.save
    end

    @job_set = JobSet.new({
                            :patient_id => @patient.id,
                            :user_id => @user.id,
                            :email_address => params[:email],
                            :phone_number => params[:phone],
                            :modified_date => Time.now,
                            :delay_in_hrs => delay_in_hrs,
                            :send_on_complete => send_on_complete,
                            :use_rsna_id => (params[:new_email] == "true" ? false : true),
                            :send_to_site => (not params[:send_to_site].blank?)
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

  # Show the cart
  def show_cart
    @exams = @cart.collect {|id| Exam.find(id) }
    @patient = @exams.first.patient if @exams and @exams.size > 0
  end

  # Add an exam to the cart
  def add_to_cart
    cart_op do |cart|
      if params[:id].class == Array
        params[:id].collect!(&:to_i)
        params[:id].delete_if {|id| cart.include?(id) }
        cart = cart + params[:id]
      else
        cart << params[:id].to_i if not params[:id].blank? and not get_cart.find {|i| i == params[:id].to_i }
      end
      cart
    end
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
