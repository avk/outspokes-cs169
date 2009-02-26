class HomeController < ApplicationController


  def index
    @sites = Site.find(:all)
    respond_to do |format|
      format.html
    end
  end

private
  
end
