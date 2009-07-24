class CommentersController < ApplicationController
  # authorize by url_token
  before_filter :login_required

  def edit
    @title = 'Preferences'
    @commenter = Commenter.find(params[:id])
  end

  def update
    @commenter = Commenter.find(params[:id])
    if @commenter.update_attributes(params[:commenter])
      flash.now[:notice] = "Preferences updated"
    else
      flash.now[:warning] = "Error updating preferencesa"
    end
    render :action => 'edit'
  end

  protected
  def login_required
    unless @invite = Invite.find_by_url_token(params[:url_token])
      access_denied
    end
  end
end
