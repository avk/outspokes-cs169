class ActivityController < ApplicationController
  
  USER_NAME, PASSWORD = "outspokesman", "inktomi2009"
  
  before_filter :authenticate
  
  def index
    @commenters = Commenter.all
    @accounts = Account.find(:all, :include => 'sites', :order => 'created_at')
  end
  
private
  
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
  
end