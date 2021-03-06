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
    @search_comments = {}
    @pages = @site.pages_with_latest_feedback
    unless params[:search].empty? or params[:search] == "Search Feedback"
      terms = params[:search].split( / *"(.*?)" *| / )
      @pages.each do |page|
        @search_comments[page.id] = Comment.find_all_by_page_id(page.id)
        @search_comments[page.id].sort! {|x,y| y.search_score(terms) <=> x.search_score(terms) }
        @search_comments[page.id] = @search_comments[page.id].find_all{|item| item.search_score(terms) > 0 }
        
        @search_comments.delete(page.id) if @search_comments[page.id].empty?
      end
      flash[:warning] = "No search results found for '#{terms}'" if @search_comments.empty?
    end
    render :action => :index
  end
end
