class Widget::SourceController < ApplicationController
    Widget::SourceController.page_cache_extension = '.js'
    caches_page :index

    def index
      @fb_hash = "fb_" + generate_hash
      @ordered_files = %w(
        fb_hash.js.erb
        fb.jQuery.js
        fb.Common.js
        fb.Interface.js
        fb.Interface.comment.js
        fb.Feedback.js
        fb.Comment.js
      )
      @ordered_files.map! { |f| (RAILS_ROOT + '/app/js/' + f).to_s }

      respond_to do |wants|
        wants.js # index.js.erb
      end
    end

  protected

    def generate_hash
      Digest::MD5::hexdigest(rand().to_s)
    end
end
