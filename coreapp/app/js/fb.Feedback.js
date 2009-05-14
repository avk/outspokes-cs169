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
        "unpopular?": "boolean"
        }),
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
    delete fb.Feedback.all[this.feedback_id];
    this.feedback_id = null;
    this.content = null;
    this.target = null;
    this.name = null;
    this.timestamp = null;
    this.build = null;
  };
  fb.Feedback.prototype.render = function() {};
  
  fb.Feedback.prototype.destroy = function() {
    if (!_fb.admin()) {
      return false;
    }
    var data = {
      url_token: fb.env.url_token,
      current_page: fb.env.current_page,
      validation_token: _fb.admin(),
      id: this.feedback_id
    };
    var self = this;
    var callback = function(data) {
      if (!data.success) {
//        console.log("delete fail!");
      } else {
//        console.log("delete win!");
          self.remove();
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
