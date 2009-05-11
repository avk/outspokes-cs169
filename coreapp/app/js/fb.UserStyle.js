  var $ = fb.$;
  /**
   * fb.UserStyle class to represent a page edit.
   * @classDescription Creates a new fb.UserStyle object
   * @param {Object} obj An object of parameters
   * @constructor
   */
  fb.UserStyle = function (obj) {
    // call to super for properties
    this.parent.call(this, obj);
    this.link = create_link(this.feedback_id);
    this.build = fb.i.user_style.build(this);

    fb.UserStyle.all[this.feedback_id] = this;
    fb.UserStyle.unrendered[this.feedback_id] = this;
  };
  
  // call to super for methods
  fb.UserStyle.prototype = new fb.Feedback();
  fb.UserStyle.prototype.constructor = fb.UserStyle;
  fb.UserStyle.prototype.parent = fb.Feedback;
  
  fb.UserStyle.prototype.remove = function() {
    // remove the comment from the interface
    // must be first
    fb.i.user_style.remove(this);
    delete fb.UserStyle.all[this.feedback_id];
    delete fb.UserStyle.unrendered[this.feedback_id];
    // super.remove:
    this.parent.prototype.remove.call(this, arguments[0]);
    fb.UserStyle.refresh_count();
    return true;
  };
  
  fb.UserStyle.prototype.render = function() {
    fb.i.user_style.render(this);
  };

//TODO give_opinion
   
  fb.UserStyle.prototype.agree = function() {
    this.giveOpinion('agree');
  };
  
  fb.UserStyle.prototype.disagree = function() {
    this.giveOpinion('disagree');
  };

  fb.UserStyle.prototype.isReply = function() {
        return fb.i.comment.dom.comment_id_format.test(this.target);
  };

  fb.UserStyle.prototype.apply = function() {
    if (fb.UserStyle.applied) {
      fb.UserStyle.applied.unapply();
    }
    $('head').append(this.link);
  };

  fb.UserStyle.prototype.unapply = function() {
    this.link.remove();
  };

  // Class variables and static functions
  fb.UserStyle.all = {};
  fb.UserStyle.unrendered = {};
  fb.UserStyle.applied = null;

  fb.UserStyle.post = function (targets) {
    if (!_fb.authorized()) {
      return null;
    }
    console.log(targets);
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page
    };
    if (_fb.admin()) {
      data.validation_token = _fb.admin();
    }
    
    var styles = {};
    $.each(targets, function (selector, target) {
      styles[selector] = "{";
      $.each(target.new_styles, function (property, value) {
        styles[selector] += "'" + property + "':'" + value.toString() + "',";
      });
      styles[selector] = styles[selector].slice(0, -1);
      styles[selector] += "}"
    });
    data.styles = styles;
    
    console.log(data);
    var callback = function(data) {
      if (! data.success) {
        fb.UserStyle.get();
        return;
      }
      new fb.UserStyle(data.user_style)
    };
    $.post(fb.env.post_user_style_address, data, callback, "json");
    return true;
  };

  fb.UserStyle.render = function() {
    for (var i in fb.UserStyle.unrendered) {
      fb.UserStyle.unrendered[i].render();
    }
    fb.UserStyle.refresh_count();
  };
  
  // This is UI and should be moved to fb.Interface.user_style
  fb.UserStyle.refresh_count = function() {
    // fb.i.set_num_comments(fb.getProperties(fb.UserStyle.all).length);
  };


  fb.UserStyle.get = function(options, callback) {
    var params = {
      'url_token': fb.env.url_token,
      'current_page': fb.env.current_page
    };
    if (typeof options === "object") {
      $.extend(params, options);
    } else if (typeof options !== "undefined") {
      callback = options;
    }
    if (_fb.admin()) {
      params.validation_token = _fb.admin();
      if (_fb.site_id()) {
        params.site_id = _fb.site_id();
      }
    }

    if (callback) {
      if (typeof callback === "string") {
        params.callback = callback;
      } else if (typeof callback === "function") {
        // do nothing
      }
    } else {
      callback = function (data) {
        fb.UserStyle.get_callback(data, true);
      };
    }

    params = "?" + $.param(params);
    if (typeof callback === "string") {
      $.getScript(fb.env.get_user_styles_address + params);
    } else {
      // jQuery.getJSON requires the "?" on callback to be unescaped
      params += "&callback=?";
      $.getJSON(fb.env.get_user_styles_address + params, callback);
    }
  };
  
  /**
   * Process the data received in response to fb.UserStyle.get()
   * @param {Object} data The retrieved JSON
   * @param {Boolean} render True => render all user styles
   * @return {Array[Feedback]} An array of the new user styles
   */
  fb.UserStyle.get_callback = function (data, render) {
    if (!(_fb.authorized() || data.authorized)) {
      return null;
    }

    var found;
    // Get the new user styles
    var new_user_styles = $.map(
      $.grep(data.styles, function(style_obj) {
        found = false;
        $.each(fb.UserStyle.all, function(feedback_id, user_style) {
          if (style_obj.feedback_id == feedback_id) {
            found = true;
            return false;
          }
        });
        return !found;
      }),
      function (style_obj) {
        return (new fb.UserStyle(style_obj));
      }
    );
    // Delete the ones that have been deleted in the backend
    $.each(fb.UserStyle.all, function(feedback_id, user_style) {
      found = false;
      $.each(data.styles, function() {
        if (this.feedback_id == feedback_id) {
          found = true;
          return false;
        }
      });
      if (!found) {
        fb.UserStyle.all[feedback_id].remove();
      }
      return true;
    });

    var selector, selector_class;
    $.each(data.selectors, function (selector_array) {
      [selector, selector_class] = selector_array;
      $(selector).addClass(selector_class);
    });

    if (render) {
      fb.UserStyle.render();
    }
    return new_user_styles;
  };



  ////////////////  Private variables/functions

  function create_link(id) {
    return rtn = $('<link rel="stylesheet" type="text/css" href="' + fb.env.user_style_address(id) + '" media="screen" />');
  }
