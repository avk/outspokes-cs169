class SeleniumController < ApplicationController
  def test_fb_hash
    @fb_hash = "fb_g3n3rat3d123"
    @file = File.join(RAILS_ROOT, 'app', 'js', 'fb_hash.js.erb')
  end
end
