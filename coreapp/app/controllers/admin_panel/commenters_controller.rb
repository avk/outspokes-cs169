class AdminPanel::CommentersController < AdminPanel::AdminController
  
  # GET /admin_panel/:site_id/commenters
  def index
    @commenters = @site.commenters
  end

  # POST /admin_panel/:site_id/commenters
  def create
    invite_commenters
    redirect_to admin_panel_commenters_path(@site)
  end

  # DELETE /admin_panel/:site_id/commenters/:id
  def destroy
    begin
      commenter = Commenter.find(params[:id])
      commenter.invites.find_by_page_id(@site.home_page).destroy
      commenter.feedbacks_for_site(@site.id).each { |f| f.destroy }
      redirect_to admin_panel_commenters_path(@site)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not remove commenter."
      render :template => "admin_panel/invalid"
    end
  end

end
