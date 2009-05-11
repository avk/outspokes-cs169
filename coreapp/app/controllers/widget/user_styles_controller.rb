class Widget::UserStylesController < Widget::WidgetController
  
  #before_filter :validate_callback, :only => [:feedback_for_page, :new_feedback_for_page, :destroy]
  before_filter :authorize
  skip_before_filter :verify_authenticity_token
  
  # GET all the user styles for a given page
  def index
    # if @authorized
    # end
    
    styles, selectors = [], []
    
    styles = @invite.page.user_styles
    styles.each do |style|
      begin
        json = JSON.parse(style.changeset)
        # REFACTOR:
        json.keys.each do |selector|
          # Adapted from UserStyle.json_to_css
          selectors[selector.to_s] = selector.gsub(/:eq/, "").gsub(/[>()]/, "").gsub(/[ ]/, "")
        end
      rescue JSON::ParserError => e
      end
    end
    
    styles = styles.map { |style| style.json_attributes(@commenter) }
    
    result = {:authorized => @authorized, :admin => @admin, :selectors => selectors, :styles => styles}
    
    respond_to do |wants|
      wants.js do
        render :json => result, :callback => params[:callback]
      end
    end
  end
  
  # GET an individual user's changes (represented by CSS) for a given page
  def show
    @css = "" # returned by default
    # if @authorized
      begin
        if @user_style = UserStyle.find( params[:id] )
          @css = UserStyle.json_to_css(@user_style.changeset)
        end
      rescue ActiveRecord::RecordNotFound => e
      end
    # end
    
    respond_to do |wants|
      wants.css
    end
  end
  
  # POST saving an individual user's changes for a given page
  def create
    if @authorized
      @user_style = UserStyle.new
      @user_style.page = @invite.page
      @user_style.commenter = @commenter
      @user_style.changeset = params[:styles]
      success = @user_style.save
      
      result = {
        :authorized => @authorized, 
        :admin => @admin, 
        :success => success, 
        :user_style => @user_style 
      }
    end
    
    respond_to do |wants|
      wants.html do
        @json_data = result.to_json
        render :template => 'widget/feedbacks/new_feedback_for_page'
      end
    end
  end

end
