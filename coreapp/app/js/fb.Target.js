  var $ = fb.$;
  /**
   * fb.Target class to represent a Target.
   * @classDescription Creates a new fb.Target object
   * @param {Object} path A CSS selector to a specific object in the DOM
   * @constructor
   */
  fb.Target = function (path) {
    this.selector = path;
    this.element = $(path);
    this.original_styles = {};
    this.new_styles = {};
  };

  fb.Target.prototype.set_style = function (property, value) {
    if (!this.original_styles.property) {
      this.original_styles.property = value;
    }
    this.new_styles.property = value;
    this.element.css(property, value);
  };

  fb.Target.prototype.delete = function () {
    this.element.css(original_styles);
    this.original_styles = null;
    this.new_styles = null;
    this.selector = null;
    this.element = null;
  };
  
  fb.Target.prototype.render = function () {
    fb.i.target.render(this);
  };

  fb.Target.pick = function (callback) {
    fb.select_target(function (e) {
      callback(new fb.Target(fb.getPath(e.target)));
    });
  };
