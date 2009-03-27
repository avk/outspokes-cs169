class FeedbackjsController < ApplicationController
  def index
    files = [
      "fb_hash.js",
      "fb.jQuery.js",
      "fb.jQuery.extensions.js",
      "fb.Interface.js",
      "fb.Interface.comment.js",
      "fb.Comment.js"]
    out = ""
    for f in files do 
      out += IO.read("app/js/" + f) + "\n"
    end
    out += "fb_hash();\n"

    render :js => out
  end

end
