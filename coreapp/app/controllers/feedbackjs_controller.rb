class FeedbackjsController < ApplicationController

  FeedbackjsController.page_cache_extension = '.js'  
  caches_page :index
  
  @@dir = "app/js/"
  @@testdir = "app/js/test/"
  @@first = "fb_hash.js"
  @@files = [
    "fb.jQuery.js",
    "fb.Common.js",
    "fb.Interface.js",
    "fb.Interface.comment.js",
    "fb.Feedback.js",
    "fb.Comment.js"]
  @@tests = [
    "test-globals.js",
    "test-success.js"]
  
  def index
    @fb_hash = "fb_" + generate_hash
    self.makejs
    @out += @fb_hash + "();"
    
    render :js => @out
  end
  
  def test
    @fb_hash = "fb"
    self.makejs
    @out = IO.read(@@testdir + "head.js") + @out
    @out += IO.read(@@testdir + "tail.js")

    @@tests.each do |f|
      @out += "/********\n * Test: " + f + "\n *******/\n"
      @out += IO.read(@@testdir + f)
    end
    
    render :js => @out
  end
  
protected
  
  def makejs
    @out = "var " + @fb_hash + " = " + IO.read(@@dir + @@first)
    @out += "  })(" + @fb_hash + ");\n};\n\n"
    pre = "\n(function(fb) {\n"
    post = "})(" + @fb_hash + ");\n\n"
    @@files.each do |f|
      @out += "//" + f + pre
      @out += IO.read(@@dir + f) + post
    end
  end

  def generate_hash
    Digest::MD5::hexdigest(rand().to_s)
  end

end
