class Widget::TagsController < ApplicationController
  
  # POST /pages/1/feedbacks/1/add_tag
  def create
    @feedback = Feedback.find(params[:id])
	  @feedback.tag_list.add(params[:tag_list].gsub(" ", "_")) 
	  @feedback.save
    flash[:notice] = 'Tag Added'
    redirect_to page_path(params[:page_id])
  end

  def delete
    @feedback = Feedback.find(params[:id])
    @feedback.tag_list.remove(params[:tag])
    @feedback.save!
    flash[:notice] = 'Tag Removed'
    redirect_to page_path(params[:page_id])
  end

end
