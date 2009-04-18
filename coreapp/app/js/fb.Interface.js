  var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
    fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.");
    if (!fb.env.authorized) {
      return false;
    }

    $('head').append('<link rel="stylesheet" type="text/css" href="' + fb.env.css_address + '" />');
    
    this.main_window = $('<div id="outspokes"><h1 id="topbar">outspokes y&#8216;all</h1></div>').css({});
    this.main_window.appendTo($('body'));
    
    this.comment = new fb.Interface.comment(this);
    
    fb.Interface.instantiated = true;
  };
  
  fb.Interface.prototype.div = function() {
  	return $('<div></div>');
  };

  fb.Interface.instantiated = false;
