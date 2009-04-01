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
    
    # We are this is a public page, we're okay
    if !@authorized && (page = Page.find_public_page_by_url(@current_page))
      @authorized = true
      @feedback = page.feedbacks.map { |f| f.json_attributes }
      @site_url = page.url
    elsif !@authorized && (site = Site.find_public_site_by_url(@current_page))
      # no feedback for this page, but it is public!
      @authorized = true
      @site_url = site.url
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
    @callback = params[:callback]
    @current_page = params[:current_page]
    @token = params[:url_token]
    @target = params[:target]
    @name = params[:name]
    @content = params[:content]
    @authorized = false
    result = create_feedback
    
    respond_to do |wants|
      wants.html do
          @json_data = result.to_json
      end
      wants.js do
        render :json => result,
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

  def create_feedback
    page, invite = get_page_and_invite_for_feedback
    site_url = 'none'
    feedback = []
    
    if !page.nil? && page.valid?
      @authorized = true
      site_url = invite ? invite.page.url : page.url
      if invite
        commenter = invite.commenter
        pub = false
      else
        commenter = nil
        pub = true
      end
      feedback = Comment.new :commenter => commenter, :name => @name, :content => @content,
                             :target => @target, :public => pub
      page.feedbacks << feedback
      if !feedback.valid?
        @authorized = false
        feedback = [] # OR, to return valid feedback, page.feedbacks.find :all
      else
        feedback = page.feedbacks.map { |f| f.json_attributes }
      end
    end
    {:authorized => @authorized, :url => site_url, :feedback => feedback}
  end
  
  def get_page_and_invite_for_feedback
    page = nil
    invite = nil
    if @name && (!@token) # Public feedback
      page = Page.find_public_page_by_url @current_page
      if page.nil? 
        if (site = Site.find_public_site_by_url @current_page)
          page = Page.new(:url => @current_page, :allow_public_comments => true)
          site.pages << page
          page = nil if !page.valid?
        end
      end
    elsif @token # private
      invite = Invite.find_by_url_token @token
      if invite and same_domain?(invite.page.url, @current_page)
        if invite.page.site.blank?
          page = invite.page if invite.page.url == @current_page
        else
          page = invite.page.site.pages.find_or_create_by_url @current_page
        end
      end
    end
    [page, invite]
  end

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
    
    # On one line to please rcov, doesn't pick the whole array up as having full coverage otherwise
    js_keywords = %w(break continue do for import new this void case default else function in return typeof while comment delete export if label switch var with abstract implements protected boolean instanceOf public byte int short char interface static double long synchronized false native throws final null transient float package true goto private catch enum throw class extends try const finally debugger super alert eval Link outerHeight scrollTo Anchor FileUpload location outerWidth Select Area find Location Packages self arguments focus locationbar pageXoffset setInterval Array Form Math pageYoffset setTimeout assign Frame menubar parent status blur frames MimeType parseFloat statusbar Boolean Function moveBy parseInt stop Button getClass moveTo Password String callee Hidden name personalbar Submit caller history NaN Plugin sun captureEvents History navigate print taint Checkbox home navigator prompt Text clearInterval Image Navigator prototype Textarea clearTimeout Infinity netscape Radio toolbar close innerHeight Number ref top closed innerWidth Object RegExp toString confirm isFinite onBlur releaseEvents unescape constructor isNan  onError Reset untaint Date java onFocus resizeBy unwatch defaultStatus JavaArray onLoad resizeTo valueOf document JavaClass onUnload routeEvent watch Document JavaObject open scroll window Element JavaPackage opener scrollbars Window escape length Option scrollBy)
    
    @callback = params[:callback]
    
    return if @callback.nil? # no callback should be OK -- return plain JSON or HTML window.name
    
    okay = true
    js_keywords.each do |word|
      if @callback.match(word)
        okay = false
        break
      end
    end
    okay = false unless @callback.match(/\A[a-zA-Z_]+[\w_]*\Z/)
    
    render :text => '{}' unless okay
  end
  
end
