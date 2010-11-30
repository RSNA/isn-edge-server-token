=begin rdoc
=Description
Scaffolding for users
=end
class UsersController < ApplicationController
  before_filter :admin_authenticate, :except => [:change_password]
  before_filter :authenticate, :only => [:change_password]
  before_filter :get_cart

  # Form for new User
  def new
    @new_user = User.new
  end

  # Form and post handler for changing password
  def change_password
    @user = User.find(session[:user_id])
    if params[:user]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash[:notice] = "Password change successful"
      end
    end
  end
 
  # Post handler for creating a new User
  def create
    #logout_keeping_session!
    @new_user = User.new(params[:new_user])
    @new_user.role_id = params[:new_user][:role_id].to_i
    #params[:new_user][:admin] == "1" ? @new_user.admin = true : @user.admin = false
    success = @new_user && @new_user.save
    if success && @new_user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      # self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "New User Created."
    else
      flash[:notice]  = "Failed to add a new user.  Please contact the site administrator."
      render :action => 'new'
    end
  end

  # List Roles of users
  def roles
    @users = User.all
  end

  # Post handler for updating roles
  def set_role
    @user = User.find(params[:id])
    @user.role_id = params[:role_id]
    if @user.save
      render :text => "Updated"
    else
      render :text => "Error: Failed to updated role"
    end
  end

end
