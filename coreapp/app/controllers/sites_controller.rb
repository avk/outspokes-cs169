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
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to new_page_commenter_path(@site.home_page) }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
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
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end
end
