module SeleniumHelper
  def render_fb_hash(fb_hash_identifier)
    @fb_hash = fb_hash_identifier
    render :file => File.join(RAILS_ROOT, 'app', 'js', 'fb_hash.js.erb')
  end
end
