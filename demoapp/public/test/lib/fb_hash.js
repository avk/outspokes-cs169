function fb_hash() {
  return (function(fb){
    var $ = fb.$;
    if (fb.env && fb.env.init) {
      return true;
    }

    fb.env = new Object();
    fb.env.current_page = window.location.href.split("?")[0];
    fb.env.url_token = $.getParams('url_token') || $.cookie('fb_url_token') || "";

    fb.env.get_address = "http://localhost:3000/feedback_for_page.js";
    fb.env.post_adddresss = "http://localhost:3000/post_feedback_for_page";
    return fb.Comment.get(fb.end_init);
  })(fb_hash);
}

(function (fb) {
  var $ = fb.$;
  fb.end_init = function(data) {
    if (!data) {
      fb.env.init = true;
      return false;
    }
    
    fb.env.authorized = data.authorized;
    if (!fb.env.authorized) {
      fb.env.init = true;
      return false;
    }
    
    if (!$.cookie("fb_hash_url_token")) {
      $.cookie("fb_url_token", fb.env.url_token);
    }
    
    fb.i = new fb.Interface();
    fb.Comment.get_callback(data, "render");
    return true;
  }
  
  fb.hasProp = function (obj, propObj) {
    for (i in propObj) {
      if (propObj[i] === "") {
        propObj[i] = "string";
      }
      if (typeof obj[i] !== propObj[i]) {
        return false;
      }
    }
    return true;
  }

  fb.isString = function (x) {
    return typeof x === "string";
  }

  fb.isObject = function (x) {
    return typeof x === "object";
  }

  fb.assert = function (bCondition, sErrorMessage) {
    if (!bCondition) {
      throw new Error(sErrorMessage);
    }
  }

  fb.assert_false = function (cond, msg) {
    return assert(cond === false, msg);
  }

  fb.includeScript = function (src) {
    var str = "<script type=\"text/javascript\" src=\""
    str += src + "\">";
    str += "</scr" + "ipt>";
    document.write(str);
  }

})(fb_hash);
