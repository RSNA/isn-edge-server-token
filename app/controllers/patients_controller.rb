class PatientsController < ApplicationController
  before_filter :authenticate
  before_filter :get_patient
  before_filter :get_cart
  hipaa_filter

  def new
    session[:patient_id] = nil
    redirect_to :action => :index
  end

  def index
  end

  def search
    sstring = params[:search]
    @patients = Patient.search(sstring)
    render :partial => "patients/results", :locals => {:patients => @patients}
  end

  def create_rsna_id
    if @patient and @rsna_id = @patient.rsna_id
      redirect_to :controller => :exams, :action => :index
    elsif @patient and params[:pin]
      @rsna_id = @patient.new_rsna_id(params[:pin])
      if @rsna_id.save
        flash[:success] = "Successfully Created a new RSNA ID"
        redirect_to :controller => :exams, :action => :index, :print_id => true
      else
        render :template => "patients/create_rsna_id"
      end
    elsif @patient
      @rsna_id = RsnaId.new
      render :template => "patients/create_rsna_id"
    else
      redirect_to :action => :index
    end
  end

  def print_rsna_id
    render :template => "patients/print_rsna_id", :layout => "print"
  end
end
