class HomeController < ApplicationController
  
  def index
    if logged_in?
      @sites = current_account.sites
    else
      @sites = []
    end
    respond_to do |format|
      format.html
    end
  end

end
