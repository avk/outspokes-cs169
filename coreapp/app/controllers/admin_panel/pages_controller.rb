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
  
  def search
    @pages = @site.pages_with_latest_feedback
    unless params[:search].empty?
      terms = params[:search].split( / *"(.*?)" *| / )
      @search_feedbacks = Hash.new
      @pages.each do |page|
        @search_feedbacks[page.id] = Feedback.find(:all, :conditions => [ "page_id = ?", page.id])
        @search_feedbacks[page.id].sort! {|x,y| y.search_score(terms) <=> x.search_score(terms) }
        @search_feedbacks[page.id]=@search_feedbacks[page.id].find_all{|item| item.search_score(terms) > 0 }
      end
    end
    render :partial => "index_pages"
  end
end
