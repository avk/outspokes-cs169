class HomeController < ApplicationController
  def index
    @email_req = EmailReq.new
    respond_to do |format|
      format.html
    end
  end
end
