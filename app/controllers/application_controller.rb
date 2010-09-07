# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  include AuthenticatedSystem

  def authenticate
    authenticate_on(:to_s)
  end

  def super_authenticate
    authenticate_on(:super?)
  end

  def admin_authenticate
    authenticate_on(:admin?)
  end

  def authenticate_on(auth_method)
    if logged_in?
      @user ||= User.find(session[:user_id])
      session[:username] = @user.login
      access_denied unless @user.send(auth_method)
    else
      access_denied
    end
  end

  private
  def cart_item_op(&block)
    session[:cart] = Marshal.dump(get_cart.collect(&block))
  end

  def cart_op
    session[:cart] = Marshal.dump(yield(get_cart))
  end

  def get_cart
    if session[:cart]
      @cart = Marshal.load(session[:cart])
    else
      @cart = []
    end
  end

  def get_patient
    if params[:patient_id]
      session[:patient_id] = params[:patient_id]
      @patient = Patient.find(params[:patient_id])
    elsif session[:patient_id]
      @patient = Patient.find(session[:patient_id])
    else
      @patient = nil
    end
  end

  def force_patient
    unless get_patient
      redirect_to :controller => :patients, :action => :index
    end
  end

  def render_cart_size
    render :text => get_cart.size
  end


end
