var fb = {
  // Our jQuery variable.  Use this instead of $ or jQuery.
  $:jQuery,
  // Only contains elements that have been added to the DOM.
  el:{},
  // Various environment variables
  env:{
    "testing":false,
    "testingData": {
      authorized:true,
      url:"google.com",
      feedback:[
       {feedback_id:1,
        name:"1234@example.com",
        timestamp:"Jan 1 1940",
        content:"Hello!  This is a GREAT site!",
        target:"html"},
       {feedback_id:2,
        name:"1265@example2.com",
        timestamp:"Jan 10 1991",
        content:"Whoohooo!  Yippee!  Does this work?",
        target:"html > body"},
       {feedback_id:3,
        name:"2439658@google.com",
        timestamp:"Sep 16 1991",
        content:"A boolean indicating if init() had been run yet",
        target:"html > body > div > h1"}]},
    "logged_in":false,
    "url_token":null,
    // A boolean indicating if init() had been run yet
    "init":false,
    // A reference to the main <body> tag
    "body":$(document.body),
    "current_page":null,
    // To be set after the first get
    "url":null,
    "comments":{}
  },

  // Initializes the environment, performing the inital GET of comments
  // and validation.
  init: function(testing, options){
    // Do not re-initialize
    if (fb.env.init) {
      return;
    }
    // Current URL with parameters removed.
    fb.env.current_page = window.location.href.split("?")[0];
    fb.env.testing = (testing) ? true : false;
    if (fb.env.testing) {
      if (options.current_page) {
        fb.env.current_page = options.current_page;
        fb.env.testing = false;
      }
    }
    fb.env.url_token = $.cookie('fb_url_token') || fb.$.getParams('url_token');
    // If url_token is non-existent, we're done.
    if (!fb.env.url_token) {
      fb.init_part2();
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
      'current_page': fb.env.current_page};
    var str = $.param(params);
    // jQuery.getJSON requires the "?" on callback to be unescaped
    str += "&callback=?"
    if (fb.env.testing) {
      fb.getComments_callback(fb.env.testingData);
      return;
    }
    console.log(str);
    $.getJSON("http://localhost:3000/feedback_for_page.js?"+str, fb.getComments_callback);
  },

  getComments_callback: function(data) {
    console.log(data);
    if (!fb.env.init) {
      fb.env.logged_in = data.authorized;
      if (!fb.env.logged_in) {
        fb.init_part2();
        return;
      }
      fb.env.url = data.url;
      $.cookie("fb_url_token");
      fb.draw_main_fb_window_and_icon();
    }
    if (fb.env.logged_in) {
      fb.render_comments(data.feedback);
    }
    if (!fb.env.init) {
      fb.init_part2;
      return;
    }
    return;
  },

  draw_main_fb_window_and_icon: function(){
    fb.el.comment_icon = fb.div().css({
      'border':'thin solid #000000',
      'position':'fixed',
      'top':'0px',
      'left':'0px'}).append($("<img src='comment.png' />"));
    fb.el.main_fb_window = new fb.Container();
    fb.el.main_fb_window.setTitle("Comments");
    fb.el.main_fb_window.comments = {};
    fb.el.main_fb_window.comments.head = fb.div();
    fb.el.main_fb_window.comments.body = fb.div();
    fb.el.main_fb_window.comments.foot = fb.div();
    fb.el.main_fb_window.comments.foot.html(
     '<form name="newcomment" action="http://localhost:3000/feedback_for_page.js" method="post" onSubmit="return fb.post_comment(this)" target="fb_iframe">\
        Comment: <input type="text" name="content">\
        <input type="submit" value="Submit">\
        <input type="hidden" name="current_page" value="'+fb.env.current_page+'">\
        <input type="hidden" name="url_token" value="'+fb.env.url_token+'">\
        <input type="hidden" name="callback" value="callback">\
        <input type="hidden" name="target" value="html">\
      </form>');
    $.each(fb.el.main_fb_window.comments,function(){
      fb.el.main_fb_window.append(this);
    });
    $(document.body).prepend(fb.el.comment_icon);
    fb.el.comment_icon.click(fb.toggle_main_fb_window_and_icon);
    fb.el.main_fb_window.build({onClose:fb.toggle_main_fb_window_and_icon}, false);
    
    //build iframe to direct form response to
    fb.el.iframe = document.createElement("iframe");
    fb.el.iframe.setAttribute("name", "fb_iframe");
    fb.el.iframe.setAttribute("id", "fb_iframe");
    fb.el.iframe.setAttribute("height", "10");
    fb.el.iframe.setAttribute("width", "10");
    fb.el.iframe.setAttribute("display", "none");
    fb.el.iframe.setAttribute("visibility", "hidden");

    document.body.appendChild(fb.el.iframe);
  },
  
  post_comment: function(form){
      //this function will end up posting the form. for now it's just a dummy function.
      return true;
  },

  toggle_main_fb_window_and_icon: function(){
    fb.el.main_fb_window.toggle();
    fb.el.comment_icon.toggle();
    return;
  },

	render_comments: function(comments){
    var c, x;
    fb.el.main_fb_window.hide();
    for (i in comments) {
      c = comments[i];
      if (fb.env.comments[c.feedback_id]) {
        fb.env.comments[c.feedback_id].posted = true;
        continue;
      }
      x = fb.build_comment(c);
      fb.env.comments[c.feedback_id] = new Object();
      fb.env.comments[c.feedback_id].obj = x;
      fb.env.comments[c.feedback_id].posted = true;
      fb.el.main_fb_window.comments.body.append(x);
    }
  },

  build_comment: function(c) {
    var rtn = fb.div().attr('style','width:100%');
    rtn.append(c.name + "<br />");
    rtn.append(c.content + "<br />");
    rtn.append(Date(c.timestamp) + "<br />");
    rtn.append("<hr style='width:80%'/><br />");
    if (c.target != "html" && c.target != "html > body") {
      var tmp = $(c.target)[0];
      tmp = fb.highlight_target(tmp);
      rtn.hover(tmp[0], tmp[1]);
    }
    return rtn;
  },

  highlight_target: function(el) {
    el = $(el);
    var par = el.wrap("<div></div>").parent();
    over = function() {
      par.css({
        'border':'3px solid green',
        'margin':'-3px'});
    }
    out = function() {
      par.css({
        'border-style':'none',
        'margin':'0px'});
    }
    return [over, out];
  },

  // Constructor for an empty div element
	div: function(){
		return $('<div></div>');
	}
};

// fb.Container class definition.
// Constructor:
//   Arguments: options, title, content
//     options - an object of options.  See below for a detailed description
//               of the object and its default values
//     title   - the title of the container.  May be either a string (text or
//               HTML) or a jQuery variable.
//     content - the content for the container.  May be either a string (text
//               or HTML) or a jQuery variable.
//     Arguments are required in-order, but not all arguments must be specified
//     (i.e., you can leave out arguments starting from the right).  If title
//     and content are not specified, then they can be set later using setTitle
//     and setContent.
//   Instance Variables:
//     this.title     - The div containing the title
//     this.content   - The div containing the content of the container
//     this.container - The div that is the container.  Note that before render()
//                      this is hidden (display:none).
// Methods: build (static), build (instance method), setTitle, setContent,
//     toggle, show, hide
//   build (static)   - builds all non-rendered containers.  Takes two arguments,
//                      options, the same as the options for buildContainers, and
//                      show (optional) that, when true will show the container
//                      after build.  Default for show is false.
//   build (instance) - Same as above, except only renders its own container.
//   setTitle         - Sets the title
//   setContent       - Sets the content
//   toggle           - toggle the visibility of this container
//   show/hide        - show/hide this container, respectively.
//   append           - appends argument to this.container
(function($) {
  // Options is an object of the form:
  //     {draggable: boolean (default true)
  //      resizable: boolean (default true)
  //      buttons:   string 'm' for minimize, 'c' for close, 'i' for iconize, separated by ',' (default 'm,c,i')
  //      skin:      string (default 'black')
  //      width:     number (default 500)
  //      height:    number (no default)
  //      icon:      string of path to icon (no default)
  //      minimized: boolean (default false)
  //      iconized:  boolean (default false)
  //      style:     string (css style string) (default "top:5px;right:5px")}
  // Not all options must be in the object.  Options not specified will be given their default value.
  fb.Container = function(options, title, content) {
    var o = {
      draggable: true,
      resizable: true,
      buttons:   'm,i,c',
      skin:      'black',
      width:     500,
      minimized: false,
      iconized:  false,
      style:     "top:5px;right:5px"};
    $.extend(o, options);
    var properties = new Object();
    var cstr = "containerPlus";
    var cstr2 = " {";
    for (var i in o) {
      if ((i == 'draggable') || (i == 'resizable')) {
        if (o[i] == true) {cstr += " " + i;}
        continue;
      }
      if (i == 'style') {continue;}
      cstr2 += i + ":'" + o[i] + "', ";
    }
    cstr2 = (cstr2 == " {") ? "" : cstr2.slice(0,cstr2.length - 2) + "}";
    cstr += cstr2;
    var styleStr = (o['style']) ? o['style'] : "";
    console.log(cstr);
    console.log(styleStr);
    properties["className"] = cstr;
    if (!(styleStr == "")) {
      properties["style"] = styleStr;
    }

    var tmp, no;
    this.title = fb.div().addClass("n");
    this.content = fb.div().addClass("content");
    this.container = fb.div().attr(properties).hide();

    no = fb.div().addClass("no");
    tmp = fb.div().addClass("ne").append(this.title);
    no.append(tmp);

    tmp = fb.div().addClass("c").append(this.content);
    tmp = fb.div().addClass("e").append(tmp);
    tmp = fb.div().addClass("o").append(tmp);
    no.append(tmp);

    tmp = fb.div().addClass("s");
    tmp = fb.div().addClass("se").append(tmp);
    tmp = fb.div().addClass("so").append(tmp);
    tmp = fb.div().append(tmp);
    no.append(tmp);

    this.container.append(no);

    this.title.append((title) ? title : "");
    this.content.append((content) ? content : "");
    fb.$(document.body).append(this.container);
    this.opts = {containment:"document", elementsPath:"elements/"};
    fb.Container.allContainers.push(this);
  }

  fb.Container.allContainers = [];

  fb.Container.build = function (options, show) {
    for (i in fb.Container.allContainers) {
      i.build(options, show);
    }
  }

  fb.Container.prototype.build = function (options, show) {
    if (options) {$.extend(this.opts, options);}
    this.container.buildContainers(this.opts);
    if (show) {this.show();}
  }

  fb.Container.prototype.setTitle = function (t) {
    this.title.empty().append(t);
  }

  fb.Container.prototype.setContent = function (c) {
    this.content.empty().append(c);
  }

  fb.Container.prototype.toggle = function() {
    this.container.toggle();
  }

  fb.Container.prototype.show = function() {
    this.container.show();
  }

  fb.Container.prototype.hide = function() {
    this.container.hide();
  }

  fb.Container.prototype.append = function(v) {
    this.content.append(v);
    return this;
  }

  fb.Container.prototype.is = function(e) {
    this.container.is(e);
  }

  fb.Container.prototype.iconize = function() {
    this.container.iconize(this.opts);
  }
})(fb.$);

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

  jQuery.fn.extend({
    getPath:jQuery.getPath
  });
})(jQuery, jQuery);

// Runs fb.init()
// Note, this must be the last call on this page.
fb.$(function() {
  // Argument true for testing

  // fb.init(true);

  // Second argument to set the current page's url (in js's eyes)
//  fb.init(false , {current_page:"http://google.com"});


  // No test, standard init
   fb.init(false);
});

