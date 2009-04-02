function fb_hash() {
  return (function(fb){
    if (fb.env && fb.env.init) {
      return true;
    }

    fb.env = new Object();
    fb.env.current_page = window.location.href.split("?")[0];
    fb.env.url_token = fb.getParams('url_token') || fb.cookie('fb_hash_url_token') || "";

    fb.env.get_address = "http://localhost:3000/feedback_for_page.js";
    fb.env.post_address = "http://localhost:3000/post_feedback_for_page";
    fb.env.opinion_address = "http://localhost:3000/opinion_on_feedback";
    return fb.Comment.get(function (data) {
      if (!data) {
        fb.env.init = true;
        return false;
      }

      fb.env.authorized = data.authorized;
      if (!fb.env.authorized) {
        fb.env.init = true;
        return false;
      }
      if (!fb.cookie("fb_hash_url_token")) {
        fb.cookie("fb_hash_url_token", fb.env.url_token);
      }

      fb.i = new fb.Interface();
      fb.Comment.get_callback(data, "render");
      return true;
    });
  })(fb_hash);
}
