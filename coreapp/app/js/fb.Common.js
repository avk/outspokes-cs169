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
  
  fb.assertTrue = function (cond, msg) {
    return fb.assert(cond === true, msg);
  };
