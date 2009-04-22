class SitesController < ApplicationController

  before_filter :login_required, :only => [ :new, :edit, :create, :destroy, :update ]
  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # POST /sites
  # POST /sites.xml
  def create
    # Checkboxes return "0" and "1", not true/false
    params[:site][:public] = params[:site][:public] == "1" ? true : false
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
        format.html { redirect_to root_path }
      rescue
        flash[:error] = "Could not create site."
        format.html { render :action => "new" }
      end
    end
  end

  # POST /sites/ajax?
  # // POST /sites.xml
  def create_ajax
    # Checkboxes return "0" and "1", not true/false
    params[:site][:public] = params[:site][:public] == "1" ? true : false
    @site = Site.new(params[:site])
    @site.account = current_account
      begin
        Site.transaction do
          @site.save!
          i = Invite.new(:page => @site.home_page, :commenter => @site.account)
          i.save!
        end
        render :update do |page|
        page.call "Effect.BlindDown", "section2"
         #flash[:notice] = 'Site was successfully created.'
         #format.html { redirect_to root_path }
      end
      rescue
        #flash[:error] = "Could not create site."
        #format.html { render :action => "new" }
      end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end
end
