class HomeController < ApplicationController
  
  def index
    if logged_in?
      @sites = current_account.sites
      @pages = current_account.pages
    else
      @sites = Site.find(:all)
      @pages = Page.find_all_by_site_id(:null)
    end
    respond_to do |format|
      format.html
    end
  end

end
