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
        format.js
        #format.js { render :update do |page|
        #  page.call "Effect.BlindDown", "section2"
        #end
        #}
      rescue
        flash[:error] = "Could not create site."
        respond_to do |format|
          format.html { render :action => "new" }
          format.js { render :action => ajax_erros }
        end
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
  
  def checkinclude
    proceede = true
    @site = Site.find(params[:id])    
    if(proceede)
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        render :action => ajax_errors
      end
    end
  end
  
  def initial_invite_commenters
    @site = Site.find(params[:id])
    if(invite_commenters)
      respond_to do |format|
        format.js
      end
    else
        render :action => :ajax_errors
    end
  end

  
end
