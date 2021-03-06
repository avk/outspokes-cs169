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
    comments = []
    page_id = nil
    if @authorized
      site = @invite.page.site
      if page = @invite.page.site.pages.find_by_url(params[:current_page])
        page_id = page.id
        comments = get_comments page
      end
    end

    # FIXME: this feels useless, why not use (@)site from Widget::WidgetController#authorize ?
    if site.nil?
      site = "null"
    end

    result = {:authorized => @authorized, :admin => @admin, :feedback => comments, :page_id => page_id}
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
      content = sanitize(params[:content], true)

      page = @invite.page.site.pages.find_or_create_by_url(params[:current_page])

      match = params[:target].match(/\Acomment_(\d+)\z/)
      parent_private = params[:isPrivate] 

      if match
        parent_id = match[1].to_i
        parent_private = Comment.find(parent_id).private
      end

      comment = Comment.new :commenter => @commenter, :content => content,
                             :target => params[:target], :private => parent_private
      page.comments << comment

      if params[:parent_id]
        # since parent_id is based on /comment_\d+/i, we extract the \d+
        parent_id = params[:parent_id].sub(/\D+/, '').to_i
        if Comment.find_by_id(parent_id).nil? # If comment doesn't exist, destroy the comment
          comment.destroy
        else
          comment.move_to_child_of parent_id
        end
      end
      if !comment.valid? or comment.frozen? # comment will be frozen if destroyed
        success = false
        comments = [] # OR, to return valid comments, page.comments.find :all
      else
        success = true
        comments = get_comments page
      end
    end

    result = {:authorized => @authorized, :admin => @admin,
              :success => success, :feedback => comments}

    push_update_to page if success

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
      @comment = Comment.find(params[:id])
      page = @comment.page
      result[:success] = @comment.destroy ? true : false
      if result[:success] then push_update_to page end
    end
    
    respond_to do |format|
      format.html do
          @json_data = result.to_json
          render :action => :new_feedback_for_page
      end
    end
  end

private
  
  # returns the appropriate comments for a page and account/commenter
  def get_comments(page)
    comments = []
    if @admin
      comments = page.comments.map { |f| f.json_attributes(@commenter) }
    elsif
      fbtemp = []
      for fb in page.comments.roots do
        if !fb.private || fb.commenter == @commenter 
          fbtemp += fb.self_and_descendants
        end
      end
      comments = fbtemp.map { |f| f.json_attributes(@commenter) }
    end
    return comments
  end
end
