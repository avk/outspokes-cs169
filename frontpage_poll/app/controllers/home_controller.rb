class HomeController < ApplicationController
  def index
    @email_req = EmailReq.new
    if flash[:old_email]
      @old_email = flash[:old_email]  #ERB::Util.html_escape(flash[:old_email])
    else
      @old_email = ""
    end
    respond_to do |format|
      format.html
    end
  end
end
