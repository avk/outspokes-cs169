(function(fb){
  var jQuery = $ = fb.$;
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
      do {
        num = el.prevAll(el[0].tagName).length;
        path = " > " + el[0].tagName.toLowerCase() + ":eq(" + el.prevAll(el[0].tagName).length + ")" + path;
        el = $(el[0].parentNode);
      } while (el[0] != document.documentElement);
      path = "html" + path;
      return path;
    },

    // Fetches parameters from the URL.
    // $.getParams() will return an object containing all parameters in
    //   the URL.  The keys will be the names of the parameters, and the
    //   values will be the values of the respective parameters.
    // $.getParams(name) will return the value of the parameter with name
    //   name, or false if it DNE.
    // $.getParams(name1,name2,name3,...) will return an object whose keys
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
    },
    
    div: function() {
      return jQuery('<div></div>');
    }
  });

  jQuery.fn.extend({
    getPath:jQuery.getPath
  });
})(fb_hash);
