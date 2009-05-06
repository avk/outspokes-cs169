  var $ = fb.$;
  /**
   * fb.PageEdit class to represent a page edit.
   * @classDescription Creates a new fb.PageEdit object
   * @param {Object} obj An object of parameters
   * @constructor
   */
  fb.PageEdit = function (obj) {
    // call to super for properties
    this.parent.call(this, obj);
    fb.assert(fb.hasProp(obj, {
        copy:"object",
        style:"object"}),
        "Object argument to fb.PageEdit constructor of wrong form");
    this.build = fb.i.page_edit.build(this);

    fb.page_edit.all[this.feedback_id] = this;
    fb.page_edit.unrendered[this.feedback_id] = this;
  };
  
  // call to super for methods
  fb.PageEdit.prototype = new fb.Feedback();
  fb.PageEdit.prototype.constructor = fb.PageEdit;
  fb.PageEdit.prototype.parent = fb.Feedback;
  
  fb.PageEdit.prototype.remove = function() {
    // remove the comment from the interface
    // must be first
    fb.i.page_edit.remove(this);
    // super.remove:
    this.parent.prototype.remove.call(this, arguments[0]);
    delete fb.PageEdit.all[this.feedback_id];
    delete fb.PageEdit.unrendered[this.feedback_id];
    return true;
  };
  
  fb.PageEdit.prototype.render = function() {
    fb.i.page_edit.render(this);
  };

//TODO give_opinion
   
  fb.PageEdit.prototype.agree = function() {
    this.giveOpinion('agree');
  };
  
  fb.PageEdit.prototype.disagree = function() {
    this.giveOpinion('disagree');
  };

  fb.PageEdit.prototype.isReply = function() {
        return fb.i.comment.dom.comment_id_format.test(this.target);
  };

  // Class variables and static functions
  fb.PageEdit.all = {};
  fb.PageEdit.unrendered = {};

  fb.PageEdit.post = function (content, target, name) {
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
  
  fb.PageEdit.post_failed = function (content, target) {
    fb.i.comment.post_failed(content, target);
  };

  fb.PageEdit.render = function() {
    for (var i in fb.PageEdit.unrendered) {
      fb.PageEdit.unrendered[i].render();
    }
    fb.PageEdit.refresh_count();
  };
  
  fb.PageEdit.refresh_count = function() {
    fb.i.set_num_comments(fb.getProperties(fb.Feedback.all).length);
  };
