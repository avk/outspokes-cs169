class AppPollsController < ApplicationController
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

end
