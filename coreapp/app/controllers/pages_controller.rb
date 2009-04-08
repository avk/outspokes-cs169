class PagesController < ApplicationController

  before_filter :login_required, :only => [ :new, :edit, :create, :destroy, :update ]

  def ajax_search
    @page = Page.find(params[:id])
    @feedbacks = Feedback.find(:all, :conditions => [ "page_id = ?", @page.id])
    if params[:search].length > 0
      then
        terms = params[:search].split( / *"(.*?)" *| / ) 
        @feedbacks.sort! {|x,y| y.search_score(terms) <=> x.search_score(terms) }
        @feedbacks=@feedbacks.find_all{|item| item.search_score(terms) > 0 }
        #render :layout => false
      end
    render :partial => "feedback", :locals => { :feedbacks => @feedbacks, :page => @page  }
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    #@feedbacks = Feedback.find(:all, :conditions => [ "page_id = ? AND content LIKE  ?", @page.id, "%Test%"])
    @feedbacks = Feedback.find(:all, :conditions => [ "page_id = ?", @page.id])
    @new_feedback = Feedback.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])
    @page.account = current_account

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to new_page_commenter_path(@page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      begin
        success = @page.update_attributes(params[:page])
      rescue
        success = false
      end
      if success
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end
  end
end
