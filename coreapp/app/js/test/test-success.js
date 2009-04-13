var test_success = (function() {
  var tests = [];
  var cur_test = null;
  var results = "";

  tests[0] = function() {
    cur_test = 0;
    arguments.callee.tmp = {};
    arguments.callee.tmp.trigger = false;
    arguments.callee.tmp.error_msg = "";
    try {
      fb();
    } catch (e) {
      arguments.callee.tmp.trigger = true;
      arguments.callee.error_msg = e.description;
    }
  };

  tests[0].timeout = 3;
  tests[0].followup = function() {
    var tmp;
    var trigger = this.tmp.trigger;
    var error_msg = this.tmp.error_msg;
    equal(trigger, false, (trigger) ? "Error message: " + error_msg : "No error on load");
    ok(fb.env.authorized, "We should be authorized");
    equal(fb.env.current_page, "http://localhost:3001/test.html", "current_page should be set properly");
    ok((fb.getPath(fb.i.main_window).search(/html > body:eq\(0\) > /) != -1), "A \"main_window\" should be in the DOM");
  };

  function equal(actual, expected, msg) {
    if (actual != expected) {
      results += cur_test + ":" + msg + "|";
    }
  }

  function ok(actual, msg) {
    equal(actual, true, msg);
  }

  return function() {
    fb.$('#getvalue')[0].innerHTML = tests.length;
    window['tests'] = tests;
    arguments.callee.results = function() {
      fb.$('#getvalue')[0].innerHTML = (results === "") ? "Success" : results;
    }
  };
})();

