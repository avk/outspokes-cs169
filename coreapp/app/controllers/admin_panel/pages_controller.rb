class AdminPanel::PagesController < ApplicationController
  
  layout 'admin_panel'
  
  before_filter :get_site
  # before_filter :login_required
  
  # GET /:site_id/pages
  def index
    # @pages = Page.find(:all, :include => :feedbacks, :conditions => { :site_id => @site.id })
    # @pages = Page.latest_feedback(@site.id)
    @pages = @site.pages_with_latest_feedback
  end
  
  # DELETE /:site_id/pages/:id
  def destroy
    begin
      @site.pages.find(params[:id]).destroy
      redirect_to admin_panel_site_pages_path(@site)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Page not found."
      render :template => "admin_panel/invalid"
    end
  end
  
protected
  
  def get_site
    begin
      @site = Site.find(params[:site_id])
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Site not found."
      render :template => "admin_panel/invalid"
    end
  end
  
end
