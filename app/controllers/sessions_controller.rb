=begin rdoc
=Description
This controller handles the login/logout function of the site.
=end

class SessionsController < ApplicationController

  # render log in form
  def new
  end

  def authenticated?
    !session[:login].nil?
  end
  # Log in the user
  # Log out the user
  def destroy
    # Ensuring the destruction of stored credentials on logout
    session[:login] = nil
    session[:password] = nil
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    #redirect_back_or_default('/')
    redirect_to controller: :patients
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
