class AdminPanel::AdminController < ApplicationController
  
  layout 'admin_panel'
  
  before_filter :get_site

  def get_site
    unless @site = Site.find_by_validation_token_and_id(params[:validation_token], params[:site_id])
      flash[:error] = "Site not found."
      render :template => "admin_panel/invalid"
    end
  end
  
end
