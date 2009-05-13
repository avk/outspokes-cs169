class Widget::WidgetController < ApplicationController
  
  layout nil

  def authorize
    @authorized = false
    @admin = false
    @public = false
    @invite = nil
    @commenter = nil
    @site = nil
    if params[:url_token]
      @invite = Invite.find_by_url_token(params[:url_token])
      return unless (@invite and same_domain?(@invite.page.url, params[:current_page]))

      site = @invite.page.site
      return if site.nil?
      @authorized = true
      @public = site.public
      @commenter = @invite.commenter
      @invite.last_visited_at = Time.now
      @invite.save!
      if @commenter == site.account
        if params[:email] and params[:password]
          if @commenter == Account.authenticate(params[:email], params[:password])
            @admin = site.new_validation_token
            return
          end
        elsif params[:validation_token]
          verified = site.verify_validation_token params[:validation_token]
          if verified
            @admin = verified
            return
          end
        end
        @authorized = false
        return
      else
        return
      end
    else
      @site = Site.find_public_site_by_url(params[:current_page])
      if @site.nil?
        if Page.find_public_page_by_url(params[:current_page])
          @public = true
          @authorized = true
        end
      else
        @public = true
        @authorized = true
        return
      end
    end
  end
  
  def push_update_to(page)
    begin
      Juggernaut.send_to_channels("parent.location.hash = '#refreshcomments';", page.id.to_s)
    rescue
      nil
    end
  end
  
end
