class ExamsController < ApplicationController
  before_filter :authenticate
  before_filter :get_cart
  before_filter :force_patient
  hipaa_filter

  def index
    @exams = @patient.exams
    @autoprint_rsna_id = (params[:print_id] ? true : false)
  end

  def send_cart
    @job_set = JobSet.new({
                            :patient_id => @patient.id,
                            :user_id => @user.id,
                            :security_pin => @patient.rsna_id.security_pin,
                            :email_address => @user.email,
                            :modified_date => Time.now
                          })
    if @job_set.save
      @cart.each do |exam_id|
        time = Time.now
        job = Job.create(:exam_id => exam_id, :job_set_id => @job_set.id, :modified_date => time)
        JobTransaction.create(:job_id => job.id, :status => 1, :status_message => "Queued", :modified_date => time)
      end
      cart_op {|cart| [] }
      flash[:notice] = "Exams have been queued for sending"
      redirect_to :action => :index
    else
      flash[:notice] = "An error occured when trying to save jobs"
      redirect_to :action => :show_cart
    end
  end

  def show_cart
    @exams = @cart.collect {|id| Exam.find(id) }
  end

  def add_to_cart
    cart_op {|cart| cart << params[:id].to_i } if not params[:id].blank? and not get_cart.find {|i| i == params[:id].to_i }
    render_cart_size
  end

  def delete_from_cart
    cart_op {|cart| cart.delete(params[:id].to_i); cart }
    render_cart_size
  end

  def empty_cart
    cart_op {|cart| [] }
    flash[:notice] = "Emptied Shopping Cart"
    redirect_to :action => :index
  end

end
