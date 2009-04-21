class AdminPanel::PagesController < AdminPanel::AdminController
  
  # GET /admin_panel/:site_id/pages
  def index
    @pages = @site.pages_with_latest_feedback
  end
  
  # DELETE /admin_panel/:site_id/pages/:id
  def destroy
    begin
      @site.pages.find(params[:id]).destroy
      redirect_to admin_panel_site_pages_path(@site)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Page not found."
      render :template => "admin_panel/invalid"
    end
  end
  
end
