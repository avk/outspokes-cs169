  var $ = fb.$;
  /**
   * fb.Comment class to represent a comment.
   * @classDescription Creates a new fb.Comment object
   * @param {Object} obj An object of parameters with keys name, content, target, timestamp, and feedback_id 
   * @constructor
   */
  fb.Comment = function (obj) {
    // call to super for properties
    this.parent.call(this, obj);
      fb.assert(fb.hasProp(obj, {
        content:"string",
        target:"string",
        "isPrivate": "boolean"}),
        "Object argument to fb.Comment constructor of wrong form: ");
    this.content = obj.content;
    this.target = obj.target;
    this.isPrivate = obj.isPrivate;
    this.num_replies = 0;
    
    this.build = fb.i.comment.build(this);

    fb.Comment.all[this.feedback_id] = this;
    fb.Comment.unrendered[this.feedback_id] = this;
  };
  
  // call to super for methods
  fb.Comment.prototype = new fb.Feedback();
  fb.Comment.prototype.constructor = fb.Comment;
  fb.Comment.prototype.parent = fb.Feedback;
  
  // Call with "true" as only arg to prevent comment backend comment deletion POST from happening
  fb.Comment.prototype.remove = function() {
    // remove remaining children
    fb.i.comment.visit_all_replies(this.build, function(c) {
      c.remove(true);
    })
    // remove the comment from the interface
    // must be first
    fb.i.comment.remove(this);
    delete fb.Comment.all[this.feedback_id];
    delete fb.Comment.unrendered[this.feedback_id];
    // super.remove:
    this.parent.prototype.remove.call(this, arguments[0]);
    fb.Comment.refresh_count();
    return true;
  };
  
  fb.Comment.prototype.render = function() {
    fb.i.comment.render(this);
  };

  fb.Comment.prototype.giveOpinion = function(opinion) {
    if (!_fb.authorized()) {
      return;
    }
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      feedback_id: this.feedback_id,
      opinion: opinion,
      callback: 'callback'
    };
    var callback = function(response) {
      if (response.authorized && response.opinion !== '') {
        eval("fb.i.comment.consensus." + opinion + "('bar_comment_' + response.feedback_id)");
        $('#' + fb.i.comment.dom.consensus_wrapper(response.feedback_id)).remove();
      } else {
        alert("Could not get your opinion on this comment.");
      }
    };
    $.post(fb.env.opinion_address, data, callback, "json");
  };
   
  fb.Comment.prototype.agree = function() {
    this.giveOpinion('agree');
  };
  
  fb.Comment.prototype.disagree = function() {
    this.giveOpinion('disagree');
  };

  fb.Comment.prototype.isReply = function() {
        return fb.i.comment.dom.comment_id_format.test(this.target);
  };
  
  fb.Comment.prototype.parent_comment = function() {
    if (this.isReply()) {
      return fb.Feedback.all[fb.i.comment.dom.number_from_id(this.target)];
    } else {
      return null;
    }
  };

  // Class variables and static functions
  fb.Comment.all = {};
  fb.Comment.unrendered = {};

  fb.Comment.post = function (content, target, name, isPrivate) {
    if (!_fb.authorized()) {
      return null;
    }
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      content: content,
      target: target,
      isPrivate: isPrivate
    };
    if (fb.i.comment.dom.comment_id_format.test(target)) {
      data.parent_id = target;
    }
    if (_fb.admin()) {
      data.validation_token = _fb.admin();
    }
    if (name) {
      data["name"] = name;
      delete data["url_token"];
    }
    var callback = function(data) {
      if (! data.success) {
        fb.Comment.get();
        return;
      }
      var x = fb.Comment.get_callback(data, "render");
      for (var i in x) {
        if (x[i].content == content && x[i].target == target) {
          return true;
        }
      }
      return fb.Comment.post_failed(content, target);
    };
    $.post(fb.env.post_address, data, callback, "json");
    return true;
  };
  
  fb.Comment.post_failed = function (content, target) {
    fb.i.comment.post_failed(content, target);
  };

  fb.Comment.render = function() {
    for (var i in fb.Comment.unrendered) {
      fb.Comment.unrendered[i].render();
    }
    // The following is UI and should be moved to fb.Interface.comment
    fb.Comment.refresh_count();
    fb.$("#comments_filter :selected").click(); // Re-sort comments based on sort/filter dropdown
  };
  
  // This is UI and should be moved to fb.Interface.comment
  fb.Comment.refresh_count = function() {
    fb.i.set_num_comments(fb.getProperties(fb.Comment.all).length);
  };


  fb.Comment.get = function(options, callback) {
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
        fb.Comment.get_callback(data, true);
      };
    }

    params = "?" + $.param(params);
    if (typeof callback === "string") {
      $.getScript(fb.env.get_address + params);
    } else {
      // jQuery.getJSON requires the "?" on callback to be unescaped
      params += "&callback=?";
      $.getJSON(fb.env.get_address + params, callback);
    }
  };
  
  /**
   * Process the data received in response to fb.Comment.get()
   * @param {Object} data The retrieved JSON
   * @param {Boolean} render True => render all comments 
   * @return {Array[Comment]} An array of the new comments
   */
  fb.Comment.get_callback = function (data, render) {
    if (!(_fb.authorized() || data.authorized)) {
      return null;
    }

    var found;
    // Get the new comments
    var new_comments = $.map(
      $.grep(data.feedback, function(feedback_obj) {
        found = false;
        $.each(fb.Comment.all, function(feedback_id, comment) {
          if (feedback_obj.feedback_id == feedback_id) {
            found = true;
            return false;
          }
        });
        return !found;
      }),
      function (feedback_obj) {
        return (new fb.Comment(feedback_obj));
      }
    );
    // Delete the ones that have been deleted in the backend
    $.each(fb.Comment.all, function(feedback_id, comment) {
      found = false;
      $.each(data.feedback, function() {
        if (this.feedback_id == feedback_id) {
          found = true;
          return false;
        }
      });
      if (!found) {
        fb.Comment.all[feedback_id].remove();
      }
      return true;
    });

    if (render) {
      fb.Comment.render();
    }
    return new_comments;
  };
