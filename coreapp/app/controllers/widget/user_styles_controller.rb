class Widget::UserStylesController < Widget::WidgetController
  
  before_filter :validate_callback, :except => [ :show ]
  before_filter :authorize, :except => [ :show ]
  
  skip_before_filter :verify_authenticity_token
  
  # GET all the user styles for a given page
  def index
    styles, selectors = [], []
    
    if @authorized
      if page = @invite.page.site.pages.find_by_url(params[:current_page])
        styles = page.user_styles
        styles.each { |style| selectors += selectors_and_class_names(style) }
        selectors.uniq!
        styles = styles.map { |style| style.json_attributes(@commenter) }
      end
    end
    
    result = { :authorized => @authorized, :admin => @admin, :selectors => selectors, :styles => styles }
    
    respond_to do |wants|
      wants.js do
        render :json => result, :callback => params[:callback]
      end
    end
  end
  
  # GET an individual user's changes (represented by CSS) for a given page
  def show
    @css = "" # returned by default
    begin
      if @user_style = UserStyle.find( params[:id] )
        @css = UserStyle.json_to_css(@user_style.changeset)
      end
    rescue ActiveRecord::RecordNotFound => e
    end
    
    respond_to do |wants|
      wants.css
    end
  end
  
  # POST saving an individual user's changes for a given page
  def create
    if @authorized
      @user_style = UserStyle.new
      @user_style.page = @invite.page.site.pages.find_or_create_by_url(params[:current_page])
      
      @user_style.commenter = @commenter
      @user_style.changeset = params[:styles]
      success = @user_style.save
      
      
      result = {
        :authorized => @authorized, 
        :admin => @admin, 
        :success => success, 
        :user_style => @user_style.json_attributes(@commenter),
        :selectors => selectors_and_class_names(@user_style)
      }
    end
    
    respond_to do |wants|
      wants.html do
        @json_data = result.to_json
        render :template => 'widget/feedbacks/new_feedback_for_page'
      end
    end
  end

private

  # returns an array of [selector, css_class_name] pairs for a given UserStyle
  def selectors_and_class_names(style)
    selectors = []
    begin
      json = ActiveSupport::JSON.decode style.changeset
      json.keys.each do |selector|
        selectors << [ selector.to_s, UserStyle.to_css_class(selector.to_s) ]
      end
    rescue ActiveSupport::JSON::ParseError => e
      logger.error "could not parse selectors: #{e}"
    end
    selectors
  end
  

end
