class Widget::OpinionsController < ApplicationController
  before_filter :validate_callback, :only => [:opinion]
  
  # Authenticity Token doesn't work with random JS calls unless we want to somehow hack that in to js?
  skip_before_filter :verify_authenticity_token, :only => [:opinion]
  
  # POST /opinion_on_feedback
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:feedback_id] => 5
  # params[:opinion] => "agree" or "disagree"
  # params[:callback] => "someFunc"
  def opinion
    @url_token = params[:url_token]
    @current_page = params[:current_page]
    @feedback_id = params[:feedback_id]
    @opinion = params[:opinion]
    
    @authorized = false
    invite = Invite.find_by_url_token(@url_token)
    if invite and same_domain?(invite.page.url, @current_page)
      @authorized = (@feedback_id.to_i <= 0) ? false : true
      if @authorized
        @commenter = invite.commenter
        case @opinion
        when /^agreed?$/
          @commenter.agree(@feedback_id)
        when /^disagreed?$/
          @commenter.disagree(@feedback_id)
        else
          @opinion = ''
          @authorized = false
        end
      end
    end
    respond_to do |wants|
      wants.html do
        @json_data = {:authorized => @authorized, :feedback_id => @feedback_id, :opinion => @opinion}.to_json
        render :template => 'widget/feedbacks/new_feedback_for_page'
      end
    end
  end
end
