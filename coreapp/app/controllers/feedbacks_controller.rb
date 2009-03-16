class FeedbacksController < ApplicationController

  before_filter :validate_callback, :only => [:feedback_for_page]

  # GET /feedback_for_page.js
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:callback] => 'some_function'
  def feedback_for_page
    @url_token = params[:url_token]
    @current_page = params[:current_page]
    
    @authorized = false
    @feedback = []
    
    invite = Invite.find_by_url_token(@url_token)
    if invite and same_domain?(invite.page.url, @current_page)
      @authorized = true
      if page = Page.find_by_url(@current_page)
        @feedback = page.feedbacks.map { |f| f.public_attributes }
      end
    end
    
    respond_to do |wants|
      wants.js do
        @feedback.map!{ |c| c.to_json }
      end
    end
  end
  
  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(@feedback.page) }
      format.xml  { head :ok }
    end
  end

protected

  def same_domain?(url1, url2)
    URI.parse(url1).host == URI.parse(url2).host
  end

  def validate_callback
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters
    
    # Also:
    # - Cannot be a JavaScript keyword
    
    @callback = params[:callback]
    render :text => '{}' unless @callback.match /\A[a-zA-Z_]+[\w_]*\Z/
  end
  
end
