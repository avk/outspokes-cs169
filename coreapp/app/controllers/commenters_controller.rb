class CommentersController < ApplicationController
  
  before_filter :get_page
  
  # GET /pages/1/commenters
  # GET /pages/1/commenters.xml
  def index
    @commenters = @page.commenters(:include => [:invites])

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
    emails = Commenter.parse_email_addresses(params[:emails])

    emails[:legal].each do |email|
      begin
        Commenter.transaction do
          if c = Commenter.find_by_email(email)
            # fails transaction if already invited to this page
            raise "double invite!" if c.pages.include? @page 
          else
            c = Commenter.new(:email => email)
            c.save!
          end
          i = Invite.new(:page => @page, :commenter => c)
          i.save!
        end
      rescue
        flash[:warning] = "Could not invite one or more of: #{emails[:legal].join(', ')}"
      end
    end
    
    unless emails[:illegal].empty?
      flash[:error] = "Could not invite #{emails[:illegal].join(', ')}"
    end

    respond_to do |format|
      unless emails[:legal].empty?
        format.html { redirect_to( page_commenters_path(@page) ) }
      else
        format.html { redirect_to(@page) }
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
