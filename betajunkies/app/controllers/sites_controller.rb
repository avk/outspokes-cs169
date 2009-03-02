class SitesController < ApplicationController

  def index
    if Project.find(:all) != nil
    	@feature = Project.find_by_id(1) #hacky!
    end
    @projects = Project.find(:all)
  end

end
