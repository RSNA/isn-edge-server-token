=begin rdoc
=Description
Filters added to this controller apply to all controllers in the application.
Likewise, all the methods added will be available for all controllers.
=end
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  include AuthenticatedSystem

  # Check if the user exists
  def authenticate
    authenticate_on(:to_s)
  end

  # Check if the user is a super user
  def super_authenticate
    authenticate_on(:super?)
  end

  # Check if the user is and administrator
  def admin_authenticate
    authenticate_on(:admin?)
  end

  # Generalized method for checking that the user can authenticate
  # and then using the specified symbol as a method to check the
  # roll of the user
  def authenticate_on(auth_method)
    if logged_in?
      @user ||= User.find(session[:user_id])
      session[:username] = @user.login
      flash[:notice] = "Your user does not have sufficient rights to access this page" unless @user.send(auth_method)
      access_denied unless @user.send(auth_method)
    else
      access_denied
    end
  end

  private
  # Perform the operation given in the block on each item in the cart
  # and store the return in place of that item in the cart
  def cart_item_op(&block)
    session[:cart] = Marshal.dump(get_cart.collect(&block))
  end

  # Perform the operation given in the block which must return a cart.
  # It yeilds the current cart and stores the new return of the block
  # as the new cart.
  def cart_op
    session[:cart] = Marshal.dump(yield(get_cart))
  end

  # Return the cart object (Array) that is stored in the session
  def get_cart
    if session[:cart]
      @cart = Marshal.load(session[:cart])
    else
      @cart = []
    end
  end

  # Return a Patient instance if a patient is specified in the params
  # or the session.  If neither is specified then the method will return
  # nil
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

  # Used to redirect away from pages that require a patient to be specified
  def force_patient
    unless get_patient
      redirect_to :controller => :patients, :action => :index
    end
  end

  # Renders a string of the cart size.
  # This is only used by ajax calls.
  def render_cart_size
    render :text => get_cart.size
  end


end
