(function (fb) {
  var $ = fb.$;
  /**
   * fb.Comment class to represent a comment.
   * @classDescription Creates a new fb.Comment object
   * @param {Object} obj An object of parameters with keys name, content, target, timestamp, and feedback_id 
   * @constructor
   */
  fb.Comment = function () {
    fb.assert(arguments.length === 1, "Incorrect number of arguments given");
    var obj = arguments[0];
    fb.assert(fb.hasProp(obj,{"name":"","content":"","target":"","timestamp":"number","feedback_id":"number"}),
          "Object argument to fb.Comment constructor of wrong form");

    this.name = obj["name"];
    this.content = decodeURI(obj["content"]);
    this.target = decodeURI(obj["target"]);
    // Javascript UTC is in terms of milliseconds
    this.timestamp = obj["timestamp"] * 1000;
    this.feedback_id = obj["feedback_id"];

    this.build = fb.i.comment.build(this);
    this.rendered = false;
    fb.Comment.all[this.feedback_id] = this;
    fb.Comment.unrendered[this.feedback_id] = this;

    // The remainder of this initializes the instance methods
    // on the first call of "new Comment()"
    if (typeof fb.Comment._initialized == "undefined") {
      fb.Comment.prototype.toString = function() {
        return "Name: "+this.name+"\nContent: "+this.content+"\nTarget: "+this.target+"\nTimestamp: "+this.timestamp;
      }

      fb.Comment.prototype.display = function() {
        alert(this.toString());
      }

      fb.Comment.prototype.remove = function() {
        fb.i.comment.remove(this);
        delete fb.Comment.all[this.feedback_id];
        delete fb.Comment.unrendered[this.feedback_id];
        this.name = null;
        this.content = null;
        this.target = null;
        this.timestamp = null;
        this.feedback_id = null;
        this.build = null;
        this.rendered = null;
        return true;
      }

      fb.Comment.prototype.render = function() {
        fb.i.comment.render(this);
      }
      
      fb.Comment.prototype.isReply = function() {
        return fb.i.comment.dom.comment_id_format.test(this.target);
      }
    }

    fb.Comment._initialized = true;
  }

  // Class variables and static functions
  fb.Comment.all = {};
  fb.Comment.unrendered = {};

  fb.Comment.get = function(callback){
    if (callback === "render") {
      callback = function (data) {
        fb.Comment.get_callback(data, true);
      }
    } else if (typeof callback === "undefined") {
      callback = fb.Comment.get_callback;
    }
    var params = {
      'url_token': fb.env.url_token,
      'current_page': fb.env.current_page
    };
    // jQuery.getJSON requires the "?" on callback to be unescaped
    params = "?" + $.param(params) + "&callback=?";
    $.getJSON(fb.env.get_address + params, callback);
  }

  /**
   * Process the data received in response to fb.Comment.get()
   * @param {Object} data The retrieved JSON
   * @param {Boolean} render True => render all comments 
   * @return {Array[Comment]} An array of the new comments
   */
  fb.Comment.get_callback = function(data, render) {
    if (!(fb.env.authorized || data.authorized)) {
      return null;
    }
    var i, j;
	
	// An array of the feedback_id's we currently have
    var oldC = [];
    for (i in fb.Comment.all) {
      oldC.push(i);
    }
    oldC.sort(function(a,b) {return a-b;});

    // An array of the feedback_id's we just recevied
	var newC = [];
	// An associative array between the feedback_id's we just
	// just received and their associated comment object.
    var newCAss = {};
    for (i in data.feedback) {
      newC.push(data.feedback[i].feedback_id);
      newCAss[data.feedback[i].feedback_id] = data.feedback[i];
    }
    newC.sort(function(a,b) {return a-b;});

    var rtn = [];
    i = j = 0;
    while (i < oldC.length && j < newC.length) {
      if (oldC[i] == newC[j]) {
        i++;
        j++;
        continue;
      } else if (oldC[i] < newC[j]) {
        fb.Comment.all[oldC[i]].remove();
        // compare next old comment with the same new comment
        i++;
        continue;
      } else {
        rtn.push(new fb.Comment(newCAss[newC[i]]));
        j++;
        continue;
      }
    }
    for (j; j < newC.length; j++) {
      rtn.push(new fb.Comment(newCAss[newC[j]]));
    }
	for (i; i < oldC.length; i++) {
      fb.Comment.all[oldC[i]].remove();
	}
    if (render) {
      fb.Comment.render();
    }
    return rtn;
  }

  fb.Comment.post = function (content, target) {
    if (!fb.env.authorized) {
      return null;
    }
    content = encodeURI(content);
    target = encodeURI(target);
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      content: content,
      target: target,
      callback: 'callback'
    }
    if (fb.i.comment.dom.comment_id_format.test(target)) {
      data.parent_id = target;
    }
    var callback = function(data) {
      var x = fb.Comment.get_callback(data, "render");
      for (var i in x) {
        if (i.content == content && i.target == target) {
          return true;
        }
      }
      return fb.Comment.post_failed(content, target);
    }
    $.post(fb.env.post_address, data, callback, "json");
    return true;
  }

  fb.Comment.post_failed = function (content, target) {
    fb.i.comment.post_failed(content, target);
  }

  fb.Comment.render = function() {
    for (var i in fb.Comment.unrendered) {
      fb.Comment.unrendered[i].render();
    }
  }
})(fb_hash);
