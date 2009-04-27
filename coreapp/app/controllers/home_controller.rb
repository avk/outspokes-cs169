class HomeController < ApplicationController
  
  def index
    if logged_in?
      redirect_to dashboard_account_url(current_account.id)
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def faq
    respond_to do |format|
      format.html
    end
  end

  def about
    respond_to do |format|
      format.html
    end
  end

end
