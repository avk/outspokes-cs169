class AppPollsController < ApplicationController
  # GET /app_polls
  # GET /app_polls.xml
  def index
    @app_polls = AppPoll.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @app_polls }
    end
  end

  # GET /app_polls/1
  # GET /app_polls/1.xml
  def show
    @app_poll = AppPoll.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @app_poll }
    end
  end

  # GET /app_polls/new
  # GET /app_polls/new.xml
  def new
    @app_poll = AppPoll.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app_poll }
    end
  end

  # GET /app_polls/1/edit
  def edit
    @app_poll = AppPoll.find(params[:id])
  end

  # POST /app_polls
  # POST /app_polls.xml
  def create
    @app_poll = AppPoll.new(params[:app_poll])

    respond_to do |format|
      if @app_poll.save
        flash[:notice] = 'AppPoll was successfully created.'
        format.html { redirect_to(@app_poll) }
        format.xml  { render :xml => @app_poll, :status => :created, :location => @app_poll }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @app_poll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /app_polls/1
  # PUT /app_polls/1.xml
  def update
    @app_poll = AppPoll.find(params[:id])

    respond_to do |format|
      if @app_poll.update_attributes(params[:app_poll])
        flash[:notice] = 'AppPoll was successfully updated.'
        format.html { redirect_to(@app_poll) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @app_poll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /app_polls/1
  # DELETE /app_polls/1.xml
  def destroy
    @app_poll = AppPoll.find(params[:id])
    @app_poll.destroy

    respond_to do |format|
      format.html { redirect_to(app_polls_url) }
      format.xml  { head :ok }
    end
  end
end
