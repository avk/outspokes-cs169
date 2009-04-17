  var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
    fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.")
    
    this.main_window = $('<div id="outspokes"></div>').css({
      'width':'300px',
      'position':'absolute',
      'top':'15px',
      'right':'15px',
      'border':'1px solid black',
      'padding':'5px'
    })
    this.main_window.appendTo($('body'));
    
    if (typeof fb.Interface._initialized === "undefined") {}
    fb.Interface._initialized = true;
    
    this.comment = new fb.Interface.comment(this);
    
    fb.Interface.instantiated = true;
  }
  
  fb.Interface.prototype.div = function() {
  	return $('<div></div>');
  }

  fb.Interface.instantiated = false;
