class Widget::OpinionsController < Widget::WidgetController
  
  before_filter :validate_callback, :only => [:create]
  before_filter :authorize
  
  # Authenticity Token doesn't work with random JS calls unless we want to somehow hack that in to js?
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  # POST /widget/opinions
  # params[:url_token] => 'abcdef'
  # params[:current_page] => 'http://hi.com/faq'
  # params[:feedback_id] => 5
  # params[:opinion] => "agree" or "disagree"
  # params[:callback] => "someFunc"
  def create
    success = false
    feedback_id = params[:feedback_id]

    if @authorized and @commenter and !@admin
      unless (feedback_id.to_i <= 0)
        case params[:opinion]
        when /^agreed?$/
          @commenter.agree(feedback_id)
          success = true
        when /^disagreed?$/
          @commenter.disagree(feedback_id)
          success = true
        end
      end
    end

    respond_to do |wants|
      wants.html do
        @json_data = {:authorized => @authorized, :admin => @admin, :success => success,
                      :feedback_id => feedback_id, :opinion => params[:opinion]}.to_json
        render :template => 'widget/feedbacks/create'
      end
    end
  end
end
