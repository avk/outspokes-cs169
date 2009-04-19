class WidgetController < ApplicationController

  WidgetController.page_cache_extension = '.js'
  caches_page :index

  def index
    @fb_hash = "fb_" + generate_hash
    @ordered_files = %w(
      fb_hash
      fb.jQuery
      fb.Common
      fb.Interface
      fb.Interface.comment
      fb.Feedback
      fb.Comment
    )
    @ordered_files.map! { |f| (RAILS_ROOT + '/app/js/' + f + '.js').to_s }
    
    respond_to do |wants|
      wants.js # index.js.erb
    end
  end

protected

  def generate_hash
    Digest::MD5::hexdigest(rand().to_s)
  end
end
