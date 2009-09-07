# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  ssl_required :new, :create

  # render new.rhtml
  def new
  end
  # 
  # def cancel_login
  #   respond_to do |format|
  #     format.html { render :partial => '/accounts/account_bar' }
  #   end
  # end

  def create
    logout_keeping_session!
    account = Account.authenticate(params[:email], params[:password])
    if account
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      reset_session
      account.update_attribute(:updated_at, Time.now)
      self.current_account = account
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    if params[:email].blank?
      flash[:error] = "Couldn't log you in."
    else
      flash[:error] = "Couldn't log you in as '#{params[:email]}'"
    end
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
