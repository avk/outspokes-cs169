class Widget::FeedbacksController < ApplicationController
  before_filter :validate_callback, :only => [:feedback_for_page, :new_feedback_for_page]
  
  # Authenticity Token doesn't work with random JS calls unless we want to somehow hack that in to js?
  skip_before_filter :verify_authenticity_token, :only => [:new_feedback_for_page]

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
        @feedback = page.feedbacks.map { |f| f.json_attributes(invite.commenter) }
      end
    end
    
    # If this is a public page, we're okay
    if @url_token.blank?
      if !@authorized && (page = Page.find_public_page_by_url(@current_page))
        @authorized = true
        @feedback = page.feedbacks.map { |f| f.json_attributes(nil) }
        @site_url = page.url
      elsif !@authorized && (site = Site.find_public_site_by_url(@current_page))
        # no feedback for this page, but it is public, so we're still authorized
        @authorized = true
        @site_url = site.url
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
    @callback = params[:callback]
    @current_page = params[:current_page]
    @token = params[:url_token]
    @target = params[:target]
    @name = params[:name]
    @content = params[:content]
    @authorized = false
    @parent_id = params[:parent_id]
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
      @name = sanitize(@name, false)
      @content = sanitize(@content, true)
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
      if @parent_id
        # since parent_id is based on /comment_\d+/i, we extract the \d+
        feedback.move_to_child_of @parent_id.sub(/\D+/, '').to_i
      end
      if !feedback.valid?
        @authorized = false
        feedback = [] # OR, to return valid feedback, page.feedbacks.find :all
      else
        feedback = page.feedbacks.map { |f| f.json_attributes(commenter) }
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
end
