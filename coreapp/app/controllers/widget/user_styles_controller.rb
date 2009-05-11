class Widget::UserStylesController < Widget::WidgetController
  
  # before_filter :validate_callback, :only => [:feedback_for_page, :new_feedback_for_page, :destroy]
  # before_filter :authorize
  
  # GET all the user styles for a given page
  def index
    if @authorized
      
    end
    
    respond_to do |wants|
      wants.js
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
  
  # def css_for_user_style
    # @stored_json =   <<-eos
    # {
    #             "html > div > div > span:eq(0)" : {
    #                 "background-color" : "#333",
    #                 "color" : "#efefef",
    #                 "font-family" : "Times New Roman, Arial, Helvetica, sans-serif"
    #             }
    #         }
    #         eos
  #           
  #   respond_to do |wants|
  #     wants.css
  #   end
  # end
    

end
