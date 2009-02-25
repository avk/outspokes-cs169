class CommentersController < ApplicationController
  # GET /commenters
  # GET /commenters.xml
  def index
    @commenters = Commenter.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commenters }
    end
  end

  # GET /commenters/1
  # GET /commenters/1.xml
  def show
    @commenter = Commenter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commenter }
    end
  end

  # GET /commenters/new
  # GET /commenters/new.xml
  def new
    @commenter = Commenter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @commenter }
    end
  end

  # GET /commenters/1/edit
  def edit
    @commenter = Commenter.find(params[:id])
  end

  # POST /commenters
  # POST /commenters.xml
  def create
    @commenter = Commenter.new(params[:commenter])

    respond_to do |format|
      if @commenter.save
        flash[:notice] = 'Commenter was successfully created.'
        format.html { redirect_to(@commenter) }
        format.xml  { render :xml => @commenter, :status => :created, :location => @commenter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @commenter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /commenters/1
  # PUT /commenters/1.xml
  def update
    @commenter = Commenter.find(params[:id])

    respond_to do |format|
      if @commenter.update_attributes(params[:commenter])
        flash[:notice] = 'Commenter was successfully updated.'
        format.html { redirect_to(@commenter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @commenter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /commenters/1
  # DELETE /commenters/1.xml
  def destroy
    @commenter = Commenter.find(params[:id])
    @commenter.destroy

    respond_to do |format|
      format.html { redirect_to(commenters_url) }
      format.xml  { head :ok }
    end
  end
end
