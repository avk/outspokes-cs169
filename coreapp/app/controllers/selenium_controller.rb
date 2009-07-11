class SeleniumController < ApplicationController
  before_filter :set_fb_hash

  def test_fb_hash
  end

  def test_fb_json
    @file = File.join(RAILS_ROOT, 'app', 'js', 'fb.json.js')
  end

  protected
  def set_fb_hash
    @fb_hash = "fb_g3n3rat3d123"
  end
end
