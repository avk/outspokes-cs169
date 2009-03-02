class CommentersController < ApplicationController
  
  before_filter :get_page
  
  # GET /pages/1/commenters
  # GET /pages/1/commenters.xml
  def index
    @commenters = Commenter.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commenters }
    end
  end

  # GET /pages/1/commenters/1
  # GET /pages/1/commenters/1.xml
  def show
    @commenter = Commenter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commenter }
    end
  end

  # GET /pages/1/commenters/new
  # GET /pages/1/commenters/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @commenter }
    end
  end

  # GET /pages/1/commenters/1/edit
  def edit
    @commenter = Commenter.find(params[:id])
  end

  # POST /pages/1/commenters
  # POST /pages/1/commenters.xml
  def create
    @commenter = Commenter.new(params[:commenter])

    respond_to do |format|
      if @commenter.save
        flash[:notice] = 'Commenter was successfully created.'
        format.html { redirect_to( page_commenter_path(@page, @commenter) ) }
        format.xml  { render :xml => @commenter, :status => :created, :location => @commenter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @commenter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1/commenters/1
  # PUT /pages/1/commenters/1.xml
  def update
    @commenter = Commenter.find(params[:id])

    respond_to do |format|
      if @commenter.update_attributes(params[:commenter])
        flash[:notice] = 'Commenter was successfully updated.'
        format.html { redirect_to( page_commenter_path(@page, @commenter) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @commenter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1/commenters/1
  # DELETE /pages/1/commenters/1.xml
  def destroy
    @commenter = Commenter.find(params[:id])
    @commenter.destroy

    respond_to do |format|
      format.html { redirect_to( page_commenters_url(@page) ) }
      format.xml  { head :ok }
    end
  end

protected
  
  def get_page
    @page = Page.find(params[:page_id])
  end
  
end
