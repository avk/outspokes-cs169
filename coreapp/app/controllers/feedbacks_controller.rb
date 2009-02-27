class FeedbacksController < ApplicationController
  # GET /feedbacks
  # GET /feedbacks.xml
  # def index
  #   @feedbacks = Feedback.find(:all)
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @feedbacks }
  #   end
  # end
  # 
  # # GET /feedbacks/1
  # # GET /feedbacks/1.xml
  # def show
  #   @feedback = Feedback.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @feedback }
  #   end
  # end
  
  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new
    @page = Page.find(params[:page_id])
    @commenter = Commenter.find(params[:commenter_id])
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.page = Page.find params[:feedback][:page_id]
    @feedback.commenter = Commenter.find params[:feedback][:commenter_id]

    respond_to do |format|
      if @feedback.save
        flash[:notice] = 'Feedback was successfully created.'
        format.html { redirect_to(@feedback) }
        format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(feedbacks_url) }
      format.xml  { head :ok }
    end
  end
end
