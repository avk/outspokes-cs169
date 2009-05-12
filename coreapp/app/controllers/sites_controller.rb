class SitesController < ApplicationController

  before_filter :login_required, :only => [ :new, :edit, :create, :destroy, :update ]
  
  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new

    # respond_to do |format|
    #     format.html # new.html.erb
    #     format.xml  { render :xml => @site }
    #   end
  end

  # POST /sites
  # POST /sites.xml
  def create
    # Checkboxes return "0" and "1", not true/false
    params[:site][:public] = params[:site][:public] == "1" ? true : false
    pageurl = params[:site][:url]
    if(params[:site][:url][params[:site][:url].length-1, 1]=='/') then params[:site][:url].chop! end
    
    # params[:site][:url] = RedirectFollower.new(params[:site][:url]).resolve.url
    
    @site = Site.new(params[:site])
    @site.account = current_account

    respond_to do |format|
      begin
        Site.transaction do
          @site.save!
          i = Invite.new(:page => @site.home_page, :commenter => @site.account)
          i.save!
        end
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to dashboard_account_path(current_account.id) }
      rescue
        flash[:error] = "Could not create site."
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      flash[:notice] = "Site was successfully deleted."
      format.html { redirect_to(dashboard_account_path(current_account.id)) }
      format.xml  { head :ok }
    end
  end
  
end
