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
      fb.assert(fb.hasProp(obj, {
        feedback_id:"number",
        name:"string",
        timestamp:"number",
        opinion:"",
        agreed:"number",
        disagreed:"number",
        "neutral?": "boolean",
        "controversial?": "boolean",
        "popular?": "boolean",
        "unpopular?": "boolean"}),
        "Object argument to fb.Feedback constructor of wrong form");
      this.feedback_id = obj.feedback_id;
      this.name = obj.name;
      this.opinion = obj.opinion;
      this.agreed = obj.agreed;
      this.disagreed = obj.disagreed;
      this.timestamp = obj.timestamp * 1000;
      this["neutral?"] = obj["neutral?"];
      this["controversial?"] = obj["controversial?"];
      this["popular?"] = obj["popular?"];
      this["unpopular?"] = obj["unpopular?"];
      this.build = null;

      fb.Feedback.all[this.feedback_id] = this;
    }
  };
  
  fb.Feedback.all = {};
  
  fb.Feedback.prototype.remove = function() {
    if(! arguments[0]) {
      if (! fb.Feedback.destroy(this.feedback_id))
        return false;
    }
    delete fb.Feedback.all[this.feedback_id];
    this.feedback_id = null;
    this.content = null;
    this.target = null;
    this.name = null;
    this.timestamp = null;
    this.build = null;
  };
  fb.Feedback.prototype.render = function() {};
  
  fb.Feedback.destroy = function(id) {
    if (!_fb.admin()) {
      return false;
    }
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      validation_token: _fb.admin(),
      id: id
    };
    var callback = function(data) {
      if (!data.success) {
//        console.log("delete fail!");
      } else {
//        console.log("delete win!");
      }
    };
    $.post(fb.env.destroy_address, data, callback, "json")
    return true;
  }
  
  /* The feedback class should also have the class variables:
   * - all: Associative array, feedback_id -> instance
   * - unrendered: Associative array, feedback_id -> instance
   * 
   * The feedback class should also implement the static methods:
   * - post()
   * - render()
   */
  
  fb.Feedback.get = function(options, callback) {
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
        fb.Feedback.get_callback(data, true);
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
   * Process the data received in response to fb.Feedback.get()
   * @param {Object} data The retrieved JSON
   * @param {Boolean} render True => render all feedbacks 
   * @return {Array[Feedback]} An array of the new feedbacks
   */
  fb.Feedback.get_callback = function (data, render) {
    if (!(_fb.authorized() || data.authorized)) {
      return null;
    }

    var found;
    // Get the new feedbacks
    var new_feedbacks = $.map(
      $.grep(data.feedback, function(feedback_obj) {
        found = false;
        $.each(fb.Feedback.all, function(feedback_id, feedback) {
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
    $.each(fb.Feedback.all, function(feedback_id, feedback) {
      found = false;
      $.each(data.feedback, function() {
        if (this.feedback_id == feedback_id) {
          found = true;
          return false;
        }
      });
      if (!found) {
        fb.Feedback[feedback_id].remove();
      }
      return true;
    });

    if (render) {
      fb.Comment.render();
    }
    return new_feedbacks;
  };
