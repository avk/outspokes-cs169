class EmailReqsController < ApplicationController
  # GET /email_reqs/1
  # GET /email_reqs/1.xml
  def show
    @email_req = EmailReq.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_req }
    end
  end

  # GET /email_reqs/new
  # GET /email_reqs/new.xml
  def new
    @email_req = EmailReq.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_req }
    end
  end

  # POST /email_reqs
  # POST /email_reqs.xml
  def create
    @email_req = EmailReq.new(params[:email_req])

    respond_to do |format|
      if @email_req.save
        format.html { render :template => 'thank_you' }
        format.xml  { render :xml => @email_req, :status => :created, :location => @email_req }
      else
        if EmailReq.find_by_email @email_req.email
          flash[:warning] = "That address has already been entered"
        elsif @email_req.email.blank?
          flash[:warning] = "Please enter an email address"
        else
          flash[:warning] = "Invalid email"
        end
        flash[:old_email] = @email_req.email
        format.html { redirect_to root_path }
        format.xml  { render :xml => @email_req.errors, :status => :unprocessable_entity }
      end
    end
  end

end
