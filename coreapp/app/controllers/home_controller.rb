class HomeController < ApplicationController
  before_filter :get_user
  
  def index
    if logged_in?
      @sites = @user.sites
      @pages = @user.pages
    else
      @sites = Site.find(:all)
      @pages = Page.find(:all)
    end
    respond_to do |format|
      format.html
    end
  end

private
  def get_user
    if logged_in?
      @user ||= Account.find(session[:account_id])
    end
  end
  
  
end
