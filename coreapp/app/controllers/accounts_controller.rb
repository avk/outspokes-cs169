class AccountsController < ApplicationController
  before_filter :login_required, :only => [:dashboard]
  
  # render new.rhtml
  def new
    @account = Account.new
  end
 
  def create
    logout_keeping_session!
    @account = Account.new(params[:account])
    success = @account && @account.save
    if success && @account.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_account = @account # !! now logged in
      flash[:notice] = "Thanks for signing up! Let's set up your first site."
      redirect_to new_site_path
    else
      flash[:error]  = "Sorry, we could not create the account."
      render :action => 'new'
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = "Account successfully updated"
        format.html { redirect_to dashboard_account_url(@account.id) }
        format.xml  { head :ok }
      else
        flash[:alert] = "Please try again"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def dashboard
    @account = Account.find(params[:id])
    @sites = @account.sites
    @sites_admin_urls = {}
    for site in @sites
      @sites_admin_urls[site] = site.admin_url
    end
    respond_to do |format|
      format.html
    end
  end

end
