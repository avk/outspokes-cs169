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
    this.build = fb.i.comment.build(this);

    fb.Comment.all[this.feedback_id] = this;
    fb.Comment.unrendered[this.feedback_id] = this;
  };
  
  // call to super for methods
  fb.Comment.prototype = new fb.Feedback();
  fb.Comment.prototype.constructor = fb.Comment;
  fb.Comment.prototype.parent = fb.Feedback;
  
  fb.Comment.prototype.remove = function() {
    // remove the comment from the interface
    // must be first
    fb.i.comment.remove(this);
    // super.remove
    this.parent.prototype.remove.call(this);
    delete fb.Comment.all[this.feedback_id];
    delete fb.Comment.unrendered[this.feedback_id];
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
        eval("fb.i.comment.consensus." + opinion + "(response.feedback_id)");
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

  // Class variables and static functions
  fb.Comment.all = {};
  fb.Comment.unrendered = {};

  fb.Comment.post = function (content, target, name) {
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
  
  fb.Comment.post_failed = function (content, target) {
    fb.i.comment.post_failed(content, target);
  };

  fb.Comment.render = function() {
    for (var i in fb.Comment.unrendered) {
      fb.Comment.unrendered[i].render();
    }
    fb.i.set_num_comments(fb.getProperties(fb.Feedback.all).length);
  };
