class FeedbackjsController < ApplicationController

  FeedbackjsController.page_cache_extension = '.js'  
  caches_page :index
  
  def index
    files = [
      "fb_hash.js",
      "fb.jQuery.js",
      "fb.Common.js",
      "fb.Interface.js",
      "fb.Interface.comment.js",
      "fb.Comment.js"]
    out = ""
    for f in files do 
      out += IO.read("app/js/" + f) + "\n"
    end
    out += "fb_hash();"
    
    render :js => out
  end

end
