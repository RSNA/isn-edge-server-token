=begin rdoc
=Description
Handling of patient searching and rsna id creation
=end
class PatientsController < ApplicationController
  before_filter :authenticate
  before_filter :get_patient
  before_filter :get_cart
  hipaa_filter

  # Reset the patient and redirect to the index
  def new
    session[:patient_id] = nil
    cart_op {|cart| [] }
    redirect_to :action => :index
  end

  # Display for ajax based search forms
  def index
  end

  # Handle search requests based on search type
  def search
    if params[:search_type] == "advanced"
      advanced_search
    else
      simple_search
    end
  end

  def record_consent
    @patient.update_attribute(:consent_timestamp, Time.now)
    redirect_to :controller => :exams, :action => :index
  end

  protected
  # Runs the query for simple searches and renders results
  def simple_search
    sstring = params[:search]
    if sstring.blank?
      render :partial => "patients/blank_search_term"
    else
      patients = Patient.search(sstring)
      render :partial => "patients/results", :locals => {:patients => patients}
    end
  end

  # Runs the query for advanced searches and renders the results
  def advanced_search
    if params[:mrn].blank? and params[:rsna_id].blank? and params[:patient_name].blank?
      render :partial => "patients/blank_search_term"
    else
      patients = Patient.search(:mrn => params[:mrn], :rsna_id => params[:rsna_id], :patient_name => params[:patient_name])
      render :partial => "patients/results", :locals => {:patients => patients}
    end
  end
end
