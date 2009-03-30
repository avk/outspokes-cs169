(function (fb) {
	var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
		fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.")
  	if (typeof fb.Interface._initialized === "undefined") {
  		
  	}
  	
  	fb.Interface._initialized = true;
		fb.Interface.instantiated = true;
  }

  fb.Interface.instantiated = false;
})(fb_hash);
