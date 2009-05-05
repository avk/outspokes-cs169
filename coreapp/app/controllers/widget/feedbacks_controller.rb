class Widget::FeedbacksController < Widget::WidgetController
  
  before_filter :validate_callback, :only => [:feedback_for_page, :new_feedback_for_page, :destroy]
  before_filter :authorize
  
  # Authenticity Token doesn't work with random JS calls unless we want to somehow hack that in to js?
  skip_before_filter :verify_authenticity_token, :only => [:new_feedback_for_page, :destroy]

  # GET /feedback_for_page.js
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:callback] => 'some_function'
  def feedback_for_page
    feedback = []

    if @authorized
      if !@public
        site = @invite.page.site
        if page = @invite.page.site.pages.find_by_url(params[:current_page])
          if @admin
            feedback = page.feedbacks.map { |f| f.json_attributes(@commenter) }
          elsif
            feedback = page.feedbacks.find(:all, :conditions => 
                       [ "private = ? OR commenter_id = ?", false, @commenter.id ]).map { |f| f.json_attributes(@commenter) }
          end
        end
      else
        if page = Page.find_public_page_by_url(params[:current_page])
          site = page.site
          feedback = page.feedbacks.map { |f| f.json_attributes(nil) }
        end
      end
    end

    if site.nil?
      site = "null"
    end

    result = {:authorized => @authorized, :admin => @admin, :feedback => feedback}
    if @admin and !params[:site_id] and site != "null"
      result.merge!({:site_id => site.id})
      if site.commenters.find(:all, :conditions => ["commenters.id != ?", site.account_id]).empty?
        result.merge!({:no_commenters => true})
      end
    end
    
    respond_to do |wants|
      wants.js do
        render :json => result, :callback => params[:callback]
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
    success = false
    if @authorized
      name = sanitize(params[:name], false)
      content = sanitize(params[:content], true)
      public_comment = @commenter.nil?

      page = nil
      if @public
        page = Page.find_public_page_by_url(params[:current_page])
        if page.nil?
          if @site
            page = Page.new(:url => params[:current_page], :allow_public_comments => true)
            @site.pages << page
            page = nil if !page.valid?
          end
        end
      else
        # if invite.page.site.blank?
        #   page = invite.page if invite.page.url == @current_page
        # else
        #   page = invite.page.site.pages.find_or_create_by_url @current_page
        # end
        page = @invite.page.site.pages.find_or_create_by_url(params[:current_page])
      end

      feedback = Comment.new :commenter => @commenter, :name => name, :content => content,
                             :target => params[:target], :public => public_comment, 
                             :private => params[:isPrivate]
      page.feedbacks << feedback

      if params[:parent_id]
        # since parent_id is based on /comment_\d+/i, we extract the \d+
        parent_id = params[:parent_id].sub(/\D+/, '').to_i
        if Feedback.find_by_id(parent_id).nil? # If feedback doesn't exist, destroy the feedback
          feedback.destroy
        else
          feedback.move_to_child_of parent_id
        end
      end
      if !feedback.valid? or feedback.frozen? # feedback will be frozen if destroyed
        success = false
        feedback = [] # OR, to return valid feedback, page.feedbacks.find :all
      else
        success = true
        feedback = page.feedbacks.map { |f| f.json_attributes(@commenter) }
      end
    end

    result = {:authorized => @authorized, :admin => @admin,
              :success => success, :feedback => feedback}

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
  
  #  DELETE /feedbacks/1
  #  DELETE /feedbacks/1.xml
  #  params[:url_token]
  #  params[:validation_token]
  #  params[:current_page]
  def destroy
    result = { :authorized => @authorized, :admin => @admin, :success => false }
    if @admin
      @feedback = Feedback.find(params[:id])
      result[:success] = @feedback.destroy ? true : false
    end
  
    respond_to do |format|
      format.html do
          @json_data = result.to_json
          render :action => :new_feedback_for_page
      end
      # format.js do
      #   render :json => result,
      #          :callback => @callback
      # end
    end
  end

end
