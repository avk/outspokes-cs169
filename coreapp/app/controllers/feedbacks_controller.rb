class FeedbacksController < ApplicationController

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    #puts Page.find params[:feedback][:page_id]
    @feedback = Feedback.new(params[:feedback])
    @feedback.page = Page.find(params[:feedback][:page_id])
    @feedback.commenter = Commenter.find(params[:feedback][:commenter_id])

    respond_to do |format|
      if @feedback.save
        flash[:notice] = 'Feedback was successfully created.'
        format.html { redirect_to(@feedback.page) }
        # format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
      else
        format.html { redirect_to(@feedback.page) }
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
