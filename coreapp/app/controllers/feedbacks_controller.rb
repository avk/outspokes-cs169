class FeedbacksController < ApplicationController

  before_filter :validate_callback, :only => [:feedback_for_page, :new_feedback_for_page]
  
  # Authenticity Token doesn't work with random JS calls unless we want to somehow hack that in to js?
  skip_before_filter :verify_authenticity_token, :only => :new_feedback_for_page

  # GET /feedback_for_page.js
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:callback] => 'some_function'
  def feedback_for_page
    @url_token = params[:url_token]
    @current_page = params[:current_page]
    
    @authorized = false
    @site_url = 'default'
    @feedback = []
    
    invite = Invite.find_by_url_token(@url_token)
    if invite and same_domain?(invite.page.url, @current_page)
      @authorized = true
      @site_url = invite.page.url
      if page = Page.find_by_url(@current_page)
        @feedback = page.feedbacks.map { |f| f.json_attributes }
      end
    end
    
    respond_to do |wants|
      wants.js do
        render :json => {:authorized => @authorized, :url => @site_url, :feedback => @feedback},
               :callback => @callback
      end
    end
  end
  
  # POST /feedback_for_page.js
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:callback] => 'some_function'
  # params[:target] => 'html'
  # params[:content] => 'blah blah blah blah'
  def new_feedback_for_page
    feedback = []
    current_page = params[:current_page]
    token = params[:url_token]
    target = params[:target]
    authorized = false
    site_url = 'none'
    page = nil
    
    invite = Invite.find_by_url_token token
    if invite and same_domain?(invite.page.url, current_page)
      if invite.page.site.blank?
        page = invite.page if invite.page.url == current_page
      # If this url is part of a site but a Page doesn't exist for it yet, create one
      elsif (page = invite.page.site.pages.find_by_url current_page) == nil
        page = Page.new(:url => current_page)
        invite.page.site.pages << page
      end
      if !page.nil?
        authorized = true
        site_url = invite.page.url
        feedback = Feedback.new(:commenter => invite.commenter, :content => params[:content], :target => target)
        page.feedbacks << feedback
        if !feedback.valid?
          authorized = false
          feedback = [] # OR, to return valid feedback, page.feedbacks.find :all
        else
          feedback = page.feedbacks.map { |f| f.json_attributes }
        end
      end
    end
    
    respond_to do |wants|
      wants.html do
          @json_data =  {:authorized => authorized, :url => site_url, :feedback => feedback}.to_json
      end
      wants.js do
        render :json => {:authorized => authorized, :url => site_url, :feedback => feedback},
               :callback => @callback
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
    URI.parse(url1).host() == URI.parse(url2).host() && URI.parse(url1).port() == URI.parse(url2).port()
  end

  def validate_callback
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters
    
    # Also:
    # - Cannot be a JavaScript keyword
    
    keywords = %w(window open location string document with case hi what)
    @callback = params[:callback]
    
    return if @callback.nil? # no callback should be OK -- return plain JSON or HTML window.name
    
    okay = true
    keywords.each do |word|
      if @callback.match(word)
        okay = false
        break
      end
    end
    okay = false unless @callback.match /\A[a-zA-Z_]+[\w_]*\Z/
    render :text => '{}' unless okay
  end
  
end
