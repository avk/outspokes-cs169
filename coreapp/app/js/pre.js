(function() {
  /* Forces any page with our widget code loaded to frame
     bust out of the admin panel iframe, and the admin panel
     iframe only.  */
  if (window.frameElement) {
    if (window.frameElement.id == 'outspokes_admin_panel_iframe') {
      top.location.replace(window.location.href);
      return;
    }
  }

  /* Creates a function which returns a set value, the value
     of which can only be set once, using .set().  */
  var _setter = function (default_value) {
    return (function() {
      var _isSet = false;
      var _value = default_value;
      var tmp = function () {
        return _value;
      };
      tmp.set = function (value) {
        _value = value;
        _isSet = true;
        this.set = function () {
          return "Uh oh!  I'm already set!"
        };
        return _value;
      };
      tmp.is_set = function () {
        return _isSet;
      };
      return tmp;
    })();
  };

  /* A variable holding values that should not be accessible
     outside of the widget code.  */
  var _fb = {};
  // Boolean for whether or not the current user is authorized
  _fb.authorized = _setter(false);
  // Boolean for whether or not the current user is the admin of the site
  _fb.admin = _setter(false);
  // Holds the side_id, null until set.
  _fb.site_id = _setter(null);
  // Holds the page_id, null until set.
  _fb.page_id = _setter(null);


