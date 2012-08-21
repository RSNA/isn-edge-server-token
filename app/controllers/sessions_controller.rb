=begin rdoc
=Description
This controller handles the login/logout function of the site.
=end
class SessionsController < ApplicationController

  # render log in form
  def new
  end

  # Log in the user
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"

      # Store the username and password in the users session so that it
      # can be passed to CTP properly. I don't think this is good security
      # but it was a committee decision as a result of a very small timeline
      session[:login] = params[:login]
      session[:password] = params[:password]
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  # Log out the user
  def destroy
    # Ensuring the destruction of stored credentials on logout
    session[:login] = nil
    session[:password] = nil
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
