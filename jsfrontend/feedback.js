var fb = {
  // Only contains elements that have been added to the DOM.
  el:{},
  // Various environment variables
  env:{
    "logged_in":false,
    // A boolean indicating if init() had been run yet
    "init":false,
    // A reference to the main <body> tag
    "body":$(document.body),
    "current_page":window.location.href
  },

  // Initializes the environment, performing the inital GET of comments
  // and validation.
  init: function(){
    // Do not re-initialize
    if (fb.env.init) {
      return;
    }
    fb.env.url_token = $.cookie('fb_url_token') || fb.getParam('url_token');
    // If url_token is non-existent, we're done.
    if (!fb.env.url_token) {
      init_part2();
    }
    fb.getComments();
    // We are not actually done.  After getting the comments, 
    return;
  },

  init_part2: function(){
    // If url_token is not valid or is non-existent, then init should be
    // true, but we don't do anything else.
    if (!fb.env.logged_in) {
      fb.env.init = true;
      return false;
    }
    fb.env.init = true;
    return true;
  },

  getComments: function() {
    var params = {
      'url_token': fb.env.url_token,
      'current_page': fb.env.current_page,
      'callback': "?"};
    var str = $.param(params);
    $.getJSON("http://fbk.com/feedback_for_page.js?"+str, fb.getComments_callback);
  },

  getComments_callback: function(data) {
    if (!fb.env.init) {
      fb.env.logged_in = data.valid;
      if (!fb.env.logged_in) {
        fb.init_part2;
        return;
      }
      fb.draw_main_fb_window_and_icon();
    }
    if (fb.env.logged_in) {
      fb.renderComments(data.comments);
    }
    if (!fb.env.init) {
      fb.init_part2;
    }
    return;
  },

  draw_main_fb_window_and_icon: function(){
    fb.el.comment_icon = fb.div().css({
      'border':'thin solid #000000',
      'position':'fixed',
      'top':'0px',
      'left':'0px'}).append($('<img src="comment.png" />'));
    fb.el.main_fb_window = {};
    fb.el.main_fb_window.container = fb.div().css({
      'display': 'none',
      'border': 'thin solid #000000',
      'position': 'fixed',
      'top': '10px',
      'right': '10px',
      'width': '200px'});
    fb.el.main_fb_window.close = $('<img src="x.png" />').css({
      'position':'absolute',
      'top':'0px',
      'right':'0px',
      'border-left':'thin solid #000000',
      'border-bottom':'thin solid #000000'});
    fb.el.main_fb_window.container.append(fb.el.main_fb_window.close);
    fb.el.main_fb_window.comments = fb.div();
    fb.el.main_fb_window.comments_heading = fb.div();
    fb.el.main_fb_window.comments_heading.html('<center>-Comments-</center>');
    fb.el.main_fb_window.comments_body = fb.div();
    // fb.el.main_fb_window.comments_body.html('Matthew: A comment');
    fb.el.main_fb_window.comments_end = fb.div();
    // fb.el.main_fb_window.comments_end.html('<a href="#" onclick="fb.load_comments.main();">get comments</a>')
    fb.el.main_fb_window.comments_new = fb.div();
    fb.el.main_fb_window.comments_new.html(
      '<form name="newcomment" action="form_action" method="post" onSubmit="return fb.new_comment(this)">\
        Name: <input type="text" name="name">\
        Comment: <input type="text" name="comment"\
        <input type="submit" value="Submit" ">\
      </form>');
    fb.el.main_fb_window.comments.append(fb.el.main_fb_window.comments_heading);
    fb.el.main_fb_window.comments.append(fb.el.main_fb_window.comments_body);
    fb.el.main_fb_window.comments.append(fb.el.main_fb_window.comments_new);
    fb.el.main_fb_window.comments.append(fb.el.main_fb_window.comments_end);
    fb.el.main_fb_window.container.append(fb.el.main_fb_window.comments);

    fb.env.body.prepend(fb.el.main_fb_window.container);
    fb.env.body.prepend(fb.el.comment_icon);

    fb.el.comment_icon.click(fb.toggle_main_fb_window_and_icon);
    fb.el.main_fb_window.close.click(fb.toggle_main_fb_window_and_icon);

    fb.el.windowed_comments = fb.div().css({'display': 'none'});
    fb.env.body.prepend(fb.el.windowed_comments);
  },

	toggle_main_fb_window_and_icon: function(){
		fb.el.main_fb_window.container.toggle();
		fb.el.windowed_comments.toggle();
		fb.el.comment_icon.toggle();
		return;
	},

	render_comments: function(comments){
    for (i in comments) {
      // fb.env.body.prepend(fb.make_windowed_comment(
      //   data.comments[i].width, data.comments[i].top, data.comments[i].left, data.comments[i].name, data.comments[i].comment));
      if(data.comments[i].type == "page") {
        fb.make_page_comment(data.comments[i].name, data.comments[i].comment);
      } else if (data.comments[i].type == "windowed") {
        fb.make_windowed_comment(data.comments[i].width, data.comments[i].top, data.comments[i].left, data.comments[i].name, data.comments[i].comment);
      }
    }
    $(function(){
      $(".containerPlus").buildContainers({
        containment:"document",
        elementsPath:"elements/"
      });
    });
  },

  // Constructor for an empty div element
	div: function(){
		return $('<div></div>');
	},

	new_comment: function(myform) {
    fb.el.main_fb_window.comments_body.append(fb.make_page_comment(myform.name.value, myform.comment.value));
    $(function(){
      $(".containerPlus").buildContainers({
        containment:"document",
        elementsPath:"elements/"
      });
    });
    return false;
  },

  make_page_comment:function(user, comment){
    fb.el.main_fb_window.comments_body.append('<div class="page_comment">'+comment+'</div><hr>');
  },

  make_windowed_comment:function(width, top, left, title, comment){
    temp = '<div class="containerPlus draggable" width="'+width+'"  style="top:'+top+'px;left:'+left+'px" buttons="m,c,i"  icon="comment-edit-48x48.png" skin="black" minimized="false">';
    temp += '<div class="no"><div class="ne"><div class="n">'+title+'</div></div>';
    temp += '<div class="o"><div class="e"><div class="c"><div class="content"><p class="fb-comment">';
    temp += comment;
    temp += '</p></div></div></div></div><div ><div class="so"><div class="se"><div class="s"></div></div></div></div></div></div>';
    fb.el.windowed_comments.prepend(temp);
  }
};

// To deal with the conflict issue regarding including jQuery, we will,
// later, do the following:
//   1. Initialize jQuery (i.e., run the code in jquery-1.3.2.js)
//   2. Call "fb.$ = jQuery.noConflict(true)".
//   3. Run all plugin definitions in a closure of the form:
//          function (jQuery, $) {
//            ...
//          }(fb.$, fb.$);

(function(jQuery, $){
  jQuery.extend({
    // Returns the CSS selector string uniquely identifying either the
    // element given as argument, or this, where this is a jQuery object
    // and this takes priority.
    //   $(document.documentElement).getPath() => 'html'
    //   $.getPath(document.documentElement) => 'html'
    getPath: function(element) {
      var el = (arguments.length == 1) ? $(element) : this;
      if (el[0] == document.documentElement) {
        return "html";
      }
      var path = "";
      var num;
      var numStr;
      do {
        num = el.prevAll(el[0].tagName).length;
        numStr = (num == 0) ? "" : ":eq(" + num + ")";
        path = " > " + el[0].tagName.toLowerCase() + numStr + path;
        el = $(el[0].parentNode);
      } while (el[0] != document.documentElement);
      path = "html" + path;
      return path;
    },

    // Fetches parameters from the URL.
    // $.getParameter() will return an object containing all parameters in
    //   the URL.  The keys will be the names of the parameters, and the
    //   values will be the values of the respective parameters.
    // $.getParameter(name) will return the value of the parameter with name
    //   name, or false if it DNE.
    // $.getParameter(name1,name2,name3,...) will return an object whose keys
    //   are name1, name2, name3, ... and whose values are the respective values
    //   or false if a parameter of the given name DNE.
    getParams: function(param) {
      var obj = new Object();
      var val;
      window.location.search.replace(
        new RegExp("([^?=&]+)(=([^&]*))?","g"),
        function( $0, $1, $2, $3 ){
          obj[ $1 ] = $3;});
      if (arguments.length > 0) {
        if (arguments.length = 1) {
          val = obj[arguments[0]];
          return (val) ? val : false;
        }
        var rtn = new Object();
        for (i in arguments) {
          val = obj[i];
          rtn[i] = (val) ? val : false;
        }
        return rtn;
      }
      return obj;
    },

    // Cookie extension
    // cookie(key): return the value of the cookie with name 'key'
    // cookie(key, value): sets the cookies of name 'key' with value 'value'
    cookie: function(key, value, options) {
      var defaults = {expires: 365, path: '/'};
      if(arguments.length > 1) {
        var o = $.extend({}, defaults, options);
        if (value === null || value === undefined) {
          value = '';
          o.expires = -1;
        }
        if (o.expires.constructor != Date) {
          var today = new Date();
          today.setDate(today.getDate() + o.expires);
          o.expires = today;
        }
        // Create the cookie string
        document.cookie =
          key + '=' + value +
          '; expires=' + o.expires.toUTCString() +
          (o.path? '; path=' + (o.path) : '') +
          (o.domain? '; domain=' + (o.domain) : '') +
          (o.secure? '; secure' : '');
      } else {
        if(result = new RegExp(key+"=(.*?)(?:;|$)").exec(document.cookie)) {
          return decodeURIComponent(result[1]);
        }
        return false;
      }
    }
  });

  jQuery.fn.extend({getPath:jQuery.getPath});
})(jQuery, jQuery);

// Runs fb.init()
// Note, this must be the last call on this page.
fb.init();

