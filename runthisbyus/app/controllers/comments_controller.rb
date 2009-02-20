class CommentsController < ApplicationController
  
  before_filter :get_idea

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @comment.idea = @idea

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'        
        format.html { redirect_to( idea_path(@idea) ) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        session[:new_comment] = @comment
        format.html { redirect_to( idea_path(@idea, :anchor => 'new_comment') ) }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy    
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to( idea_path(@idea) ) }
      format.xml  { head :ok }
    end
  end

protected
  
  def get_idea
    @idea = Idea.find(params[:idea_id])
  end
    
end
