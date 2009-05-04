class AdminPanel::CommentersController < AdminPanel::AdminController
  
  # GET /admin_panel/:site_id/commenters
  def index
    @commenters = @site.commenters.find(:all, :conditions => ["commenters.id != ?", @site.account_id])
    @commenters_commented = []; @commenters_visited = []; @commenters_not_visited = [];
    @commenters.each do |commenter|
      if (commenter.last_visited_at)
        if (commenter.feedbacks) and (not commenter.feedbacks.select { |fb| fb.page.site == @site }.empty? )
          @commenters_commented.push(commenter)
        else
          @commenters_visited.push(commenter)
        end

      else
        @commenters_not_visited.push(commenter)
      end
    end

    @total_commenters = @commenters_commented.size + @commenters_visited.size + @commenters_not_visited.size 
    flash[:warning] = "You haven't invited anyone to give feedback." if @total_commenters == 0
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
