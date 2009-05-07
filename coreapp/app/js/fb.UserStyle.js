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
    fb.assert(fb.hasProp(obj, {
        copy:"object",
        style:"object"}),
        "Object argument to fb.UserStyle constructor of wrong form");
    this.build = fb.i.user_style.build(this);

    fb.user_style.all[this.feedback_id] = this;
    fb.user_style.unrendered[this.feedback_id] = this;
  };
  
  // call to super for methods
  fb.UserStyle.prototype = new fb.Feedback();
  fb.UserStyle.prototype.constructor = fb.UserStyle;
  fb.UserStyle.prototype.parent = fb.Feedback;
  
  fb.UserStyle.prototype.remove = function() {
    // remove the comment from the interface
    // must be first
    fb.i.user_style.remove(this);
    // super.remove:
    this.parent.prototype.remove.call(this, arguments[0]);
    delete fb.UserStyle.all[this.feedback_id];
    delete fb.UserStyle.unrendered[this.feedback_id];
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

  // Class variables and static functions
  fb.UserStyle.all = {};
  fb.UserStyle.unrendered = {};

  fb.UserStyle.post = function (content, target, name) {
    if (!_fb.authorized()) {
      return null;
    }
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      content: content,
      target: target
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
        fb.Feedback.get();
        return;
      }
      var x = fb.Feedback.get_callback(data, "render");
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
  
  fb.UserStyle.post_failed = function (content, target) {
    fb.i.comment.post_failed(content, target);
  };

  fb.UserStyle.render = function() {
    for (var i in fb.UserStyle.unrendered) {
      fb.UserStyle.unrendered[i].render();
    }
    fb.UserStyle.refresh_count();
  };
  
  fb.UserStyle.refresh_count = function() {
    fb.i.set_num_comments(fb.getProperties(fb.Feedback.all).length);
  };
