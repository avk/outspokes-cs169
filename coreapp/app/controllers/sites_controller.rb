class SitesController < ApplicationController

  before_filter :login_required, :only => [ :new, :edit, :create, :destroy, :update ]
  
  # GET /sites/new
  def new
    @site = Site.new
  end
  
  # GET /sites/1/embed
  def embed
    @site = Site.find(params[:id])
  end
  
  # POST /sites
  # POST /sites.xml
  def create
    if(params[:site][:url][params[:site][:url].length-1, 1]=='/') then params[:site][:url].chop! end
    
    @site = Site.new(params[:site])
    @site.account = current_account

    respond_to do |format|
      begin
        Site.transaction do
          @site.save!
          i = Invite.new(:page => @site.home_page, :commenter => @site.account)
          i.save!
        end
        format.html { redirect_to embed_site_path(@site) }
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
      flash[:notice] = "Deleted \"#{@site.name}\". You should now remove the Outspokes script from your site."
      format.html { redirect_to(dashboard_account_path(current_account.id)) }
      format.xml  { head :ok }
    end
  end
  
end
