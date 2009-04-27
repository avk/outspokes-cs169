class HomeController < ApplicationController
  
  def index
    if logged_in?
      redirect_to dashboard_account_url(current_account.id)
    end
  end

end
