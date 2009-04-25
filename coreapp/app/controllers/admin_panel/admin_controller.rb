class AdminPanel::AdminController < ApplicationController
  
  layout 'admin_panel'
  
  before_filter :get_site

  def get_site
    begin
      @site = Site.find(params[:site_id])
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Site not found."
      render :template => "admin_panel/invalid"
    end
  end
  
end
