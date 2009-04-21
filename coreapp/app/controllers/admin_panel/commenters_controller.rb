class AdminPanel::CommentersController < ApplicationController
  
  layout 'admin_panel'
  
  before_filter :get_site
  
  def index
    @commenters = @site.commenters
  end

  def create
    emails = Commenter.parse_email_addresses(params[:emails])
    
    emails[:legal].each do |email|
      begin
        Commenter.transaction do
          if c = Commenter.find_by_email(email)
            # fails transaction if already invited to this page
            raise "double invite!" if c.pages.include? @site.home_page
          else
            c = Commenter.new(:email => email)
            c.save!
          end
          i = Invite.new(:page => @site.home_page, :commenter => c)
          i.save!
        end
      rescue
        flash[:warning] = "Could not invite one or more of: #{emails[:legal].join(', ')}"
      end
    end
    
    unless emails[:illegal].empty?
      flash[:error] = "Could not invite #{emails[:illegal].join(', ')}"
    end
    
    redirect_to admin_panel_commenters_path(@site)
  end

  def destroy
    begin
      commenter = Commenter.find(params[:id])
      commenter.invites.find_by_page_id(@site.home_page).destroy
      commenter.feedbacks_for_site(@site.id).each { |f| f.destroy }
      redirect_to admin_panel_commenters_path(@site)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not remove commenter."
      render :template => "admin_panel/invalid"
    end
  end

protected
  
  def get_site
    begin
      @site = Site.find(params[:site_id])
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Site not found."
      render :template => "admin_panel/invalid"
    end
  end
  
end
