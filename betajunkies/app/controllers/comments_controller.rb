class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
	@comment.project = Project.find(params[:project_id])
	@comment.user = User.find(session[:user_id])
	@comment.date = Time.now
	@comment.tag_list.add(@comment.user.login)


    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@comment.project) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { redirect_to(@comment.project) }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def createthreaded
    @comment = Comment.new(params[:comment])
       @comment.parent = params[:comment][:parent]
       @comment.user = User.find(session[:user_id])
       @comment.date = Time.now
@comment.tag_list.add(@comment.user.login)

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
	@parent = Comment.find_by_id(@comment.parent)
	while @parent.project == nil
            @parent = Comment.find_by_id(@parent.parent)
	end
	format.html { redirect_to(@parent.project) }
	format.xml { render :xml => @comment, :status => :created, location => @comment }
      else
        format.html { redirect_to(@comment.project) }
	format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment.project) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@comment.project) }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(@comment.project) }
      format.xml  { head :ok }
    end
  end

end
