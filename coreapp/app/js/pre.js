(function() {
  if (window.frameElement) {
    if (window.frameElement.id == 'outspokes_admin_panel_iframe') {
      top.location.replace(window.location.href);
      return;
    }
  }

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

  var _fb = {};
  _fb.authorized = _setter(false);
  _fb.admin = _setter(false);
  _fb.site_id = _setter(null);


