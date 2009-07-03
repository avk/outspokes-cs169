class Widget::SourceController < Widget::WidgetController
    Widget::SourceController.page_cache_extension = '.js'
    caches_page :index

    def index
      @site = Site.find(params[:id])
      @fb_hash = "fb_" + generate_hash
      @ordered_files = %w(
        pre.js
        fb_hash.js.erb
        fb.json.js
        fb.jQuery.js
        fb.Common.js
        fb.Interface.js
        fb.Interface.comment.js
        fb.Interface.user_style.js
        fb.Interface.target.js
        fb.Target.js
        fb.Feedback.js
        fb.Comment.js
        fb.UserStyle.js
      )
      @ordered_files.map! { |f| (RAILS_ROOT + '/app/js/' + f).to_s }
      if(@site)
        respond_to do |wants|
          wants.js # index.js.erb
        end
      end
    end

  protected

    def generate_hash
      Digest::MD5::hexdigest(rand().to_s)
    end
end
