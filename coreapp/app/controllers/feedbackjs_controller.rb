class FeedbackjsController < ApplicationController
  def index
    files = [
      "fb_hash.js",
      "fb.jQuery.js",
      "fb.jQuery.extensions.js",
      "fb.Interface.js",
      "fb.Interface.comment.js",
      "fb.Comment.js",
      "runApp.js"]
    out = ""
    for f in files do 
      out += IO.read("app/js/" + f) + "\n"
    end

    render :update do |page|
      page << out
    end
  end

end
