  var $ = fb.$;
  
  // Returns the CSS selector string uniquely identifying the element
  // given as argument
  //   fb.getPath(document.documentElement) => 'html'
  // Also exists as a jQuery extension:
  //   $(document.documentElement).getPath() => 'html'
  fb.getPath = function(element) {
    var el = $(element);
    if (el[0] == document.documentElement) {
      return "html";
    }
    var path = "";
    var num;
    do {
      num = el.prevAll(el[0].tagName).length;
      path = " > " + el[0].tagName.toLowerCase() + ":eq(" + el.prevAll(el[0].tagName).length + ")" + path;
      el = $(el[0].parentNode);
    } while (el[0] != document.documentElement);
    path = "html" + path;
    return path;
  };
  // Add fb.getPath as an extension to jQuery
  $.fn.extend({
    getPath: function() {
      return fb.getPath(this.get(0));
    }
  });

  // Fetches parameters from the URL.
  // $.getParams() will return an object containing all parameters in
  //   the URL.  The keys will be the names of the parameters, and the
  //   values will be the values of the respective parameters.
  // $.getParams(name) will return the value of the parameter with name
  //   name, or false if it DNE.
  // $.getParams(name1,name2,name3,...) will return an object whose keys
  //   are name1, name2, name3, ... and whose values are the respective values
  //   or false if a parameter of the given name DNE.
  fb.getParams = function(param) {
    var obj = {};
    var val;
    window.location.search.replace(
      new RegExp("([^?=&]+)(=([^&]*))?","g"),
      function( $0, $1, $2, $3 ){
        obj[ $1 ] = $3;});
    if (arguments.length > 0) {
      if (arguments.length == 1) {
        val = obj[arguments[0]];
        return (val) ? val : false;
      }
      var rtn = {};
      for (var i in arguments) {
        val = obj[i];
        rtn[i] = (val) ? val : false;
      }
      return rtn;
    }
    return obj;
  };
  
  // Cookie tool
  // cookie(key): return the value of the cookie with name 'key'
  // cookie(key, value): sets the cookies of name 'key' with value 'value'
  fb.cookie = function(key, value, options) {
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
      var result = new RegExp(key+"=(.*?)(?:;|$)").exec(document.cookie);
      if(result) {
        return decodeURIComponent(result[1]);
      }
      return false;
    }
  };

  fb.find_fb = function() {
    var possible = [];
    var stuff = [];
    for (var i in window) {
      if (i.search("fb") === 0) {
        possible.push(i);
      }
    }

    var correct = [];
    for (var i in possible) {
      if (window[possible[i]] === fb) {
        correct.push(possible[i]);
      }
    }

    fb.assert(correct.length === 1, "There should be only one variable that matches fb");
    return correct[0];
  };

  fb.rand_string = function (len) {
    if (!(len > 0)) {
      return "";
    }
    var vals = "abcdefghijklmnopqrstuvwxyz0123456789".split("");
    var str = vals[Math.floor(Math.random()*25)];
    len -= 1;
    for (len; len > 0; len--) {
      str += vals[Math.floor(Math.random()*35)];
    }
    return str;
  };

  /**
   * For a timestamp less than 60 minutes ago, returns a string like
   *              45 minutes ago
   * Otherwise, formats the time as something like
   *              2009/04/24 3:14 PM
   */
  fb.get_timestamp = (function() {
    function _make_length (num, len) {
      var rtn = num.toString();
      while (rtn.length < len) {
        rtn = "0" + rtn;
      }
      return rtn;
    }
    return function (seconds) {
      var d = new Date(seconds);
      var diff_min = Math.ceil(((new Date()) - d)/1000/60);
      var rtn = "";
      if (diff_min < 60) {
        rtn += diff_min + " ";
        rtn += (diff_min == 1) ? "minute" : "minutes";
        rtn += " ago";
      } else {
        rtn += _make_length(d.getMonth(), 2) + "/";
        rtn += _make_length(d.getDate(), 2) + "/";
        rtn += d.getFullYear() + " ";
        rtn += ((d.getHours() % 12 == 0) ? 12 : (d.getHours() % 12)) + ":";
        rtn += _make_length(d.getMinutes(), 2) + " ";
        rtn += (d.getHours() < 12) ? "AM" : "PM";
      }
      return rtn;
    };
  })();

  fb.select_target = function (select_function) {
    // Attach to every element _inside_ of body and filter out all elements that are part of Outspokes
    var page_elements = $("body *:not(#outspokes *, #outspokes, #outspokes_admin_panel," + 
      " #outspokes_admin_panel *, #outspokes_overlay, #outspokes_overlay *)");
    // Mark clicked-on elemement
    page_elements.bind('mouseup.elem_select', function (e) {
      select_function(e);
      page_elements.unbind(".elem_select");
      $(e.target).css('outline', "3px solid red");
      e.stopPropagation();
    });
    // Store old outline style as a property of each element to be restored later
    // TODO: Store each individual outline style instead of 'outline' as JS breaks CSS up oddly
    page_elements.bind("mouseenter.elem_select", function (e) {
      if ("__old_style" in $(e.target).parent().get(0)) {
        $(e.target).parent().eq(0).css('outline', $(e.target).parent().get(0).__old_style);
        delete $(e.target).parent().get(0)["__old_style"];
      }
      e.target.__old_style = $(e.target).css('outline')
      $(e.target).css('outline','green solid 2px')
      e.stopPropagation();
    });
    // Don't un-highlight if the element has been clicked on
    page_elements.bind("mouseleave.elem_select", function (e) {
      $(e.target).css('outline', e.target.__old_style);
      delete e.target["__old_style"];
      e.stopPropagation();
    });
  };
  
  fb.hasProp = function (obj, propObj) {
    for (var i in propObj) {
      if (propObj[i] === "") {
        propObj[i] = "string";
      }
      if (typeof obj[i] !== propObj[i]) {
        return false;
      }
    }
    return true;
  };
  
  fb.getProperties = function(obj) {
    var props = [];
    for (var x in obj) {
      props.push(x);
    }
    return props;
  };

  fb.isString = function (x) {
    return typeof x === "string";
  };

  fb.isObject = function (x) {
    return typeof x === "object";
  };

  fb.assert = function (cond, msg) {
    if (!cond) {
      throw new Error(msg);
    }
  };

  fb.assert_false = function (cond, msg) {
    return fb.assert(cond === false, msg);
  };
