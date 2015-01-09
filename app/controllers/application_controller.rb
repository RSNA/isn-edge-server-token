=begin rdoc
=Description
Filters added to this controller apply to all controllers in the application.
Likewise, all the methods added will be available for all controllers.
=end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Check if the user exists

  def authenticate
    @logged_in = nil
    @sso_groups = []
    @user = nil
    @sso_cookie_name ||= SSO::get_cookie_name
    @sso_token_str ||= cookies[@sso_cookie_name.to_sym]

    if SSO::valid_token? @sso_token_str
      @logged_in = true
      user_attrs = SSO::get_attributes(@sso_token_str)
      uid = user_attrs["uid"].first
      @user = User.find_by_user_login(uid)
      if @user.nil?
        @user = User.new(user_login: uid,
                         user_name: user_attrs["cn"].first,
                         role_id: 0)
        @user.save
      end
      @sso_groups = user_attrs[:roles] || []

    end

    if @logged_in.nil?
      redirect_to SSO::get_redirect_url(request.original_url).to_s
    end

  end

  # Check if the user is a super user
  def super_authenticate
    @sso_groups.include?("Super") || @sso_groups.include?("Admin")
  end

  # Check if the user is and administrator
  def admin_authenticate
    @sso_groups.include?("Admin")
  end

  protected

  def logged_in?
    !@logged_in.nil?
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
