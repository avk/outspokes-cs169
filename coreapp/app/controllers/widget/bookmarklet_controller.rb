class Widget::BookmarkletController < ApplicationController

  before_filter :login_required

  def index
    from_url = request.env['HTTP_REFERER']
    if params[:has_frames]
      @frames = true
    else
      unless @site = current_account.find_site_by_url(from_url)
        @site = Site.new(:url => from_url)
        current_account.sites << @site
      end
      
      @url_token = @site.admin_url_token
    end
    
    respond_to do |wants|
      wants.js # index.js.erb
    end
  end

protected

  def login_required
    unless current_account
      respond_to do |wants|
        wants.js { render :template => 'widget/bookmarklet/login' }
      end
    end
  end

end
