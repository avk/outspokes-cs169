(function(fb) {
  var $ = fb.$;
  /**
   * The Feedback superclass.
   * Mimicks the Feedback superclass in the backend.
   * @classDescription The Feedback superclass.
   * @param {Object} obj An object of parameters with keys feedback_id, content, target, name, and timestamp 
   * @constructor
   */
  fb.Feedback = function(obj) {
    if (obj) {
      fb.assert(arguments.length === 1, "Incorrect number of arguments");
      fb.assert(fb.hasProp(obj,
         {feedback_id:"number",
          content:"string",
          target:"string",
          name:"string",
          timestamp:"number"}),
        "Object argument to fb.Feedback constructor of wrong form");
      this.feedback_id = obj.feedback_id;
      this.content = decodeURI(obj.content);
      this.target = decodeURI(obj.target);
      this.name = obj.name;
      this.timestamp = obj.timestamp;
      this.build = null;

      fb.Feedback.all[this.feedback_id] = this;
    }
  }
  
  fb.Feedback.all = {};
  
  fb.Feedback.prototype.remove = function() {
    delete fb.Feedback.all[this.feedback_id];
    this.feedback_id = null;
    this.content = null;
    this.target = null;
    this.name = null;
    this.timestamp = null;
    this.build = null;
  }
  fb.Feedback.prototype.render = function() {}
  
  /* The feedback class should also have the class variables:
   * - all: Associative array, feedback_id -> instance
   * - unrendered: Associative array, feedback_id -> instance
   * 
   * The feedback class should also implement the static methods:
   * - post()
   * - render()
   */
  
  fb.Feedback.get = function(callback) {
    if (callback === "render") {
      callback = function (data) {
        fb.Feedback.get_callback(data, true);
      }
    } else if (typeof callback === "undefined") {
      callback = fb.Feedback.get_callback;
    } else {
      fb.assertTrue(typeof callback === "function", "Callback argument to fb.Feedback.get() must be a function.");
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
   * Process the data received in response to fb.Feedback.get()
   * @param {Object} data The retrieved JSON
   * @param {Boolean} render True => render all feedbacks 
   * @return {Array[Feedback]} An array of the new feedbacks
   */
  fb.Feedback.get_callback = function (data, render) {
    if (!(fb.env.authorized || data.authorized)) {
      return null;
    }
    var i, j;

    // An array of the feedback_id's we currently have
    var oldC = [];
    for (i in fb.Feedback.all) {
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
        fb.Feedback.all[oldC[i]].remove();
        // compare next old comment with the same new comment
        i++;
        continue;
      } else {
        // Assume feedback is of type Comment right now
        rtn.push(new fb.Comment(newCAss[newC[i]]));
        j++;
        continue;
      }
    }
    for (j; j < newC.length; j++) {
      rtn.push(new fb.Comment(newCAss[newC[j]]));
    }
    for (i; i < oldC.length; i++) {
      fb.Feedback.all[oldC[i]].remove();
    }
    if (render) {
      fb.Comment.render();
    }
    return rtn;
  }
})(fb_hash);
