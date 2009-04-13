var test_globals = (function() {
  var tests = [];
  var cur_test = null;
  var results = "";

  tests[0] = function() {
    cur_test = 0;
    equal(fb.globals_info.news.length, 0, "There should be no new global variables");
    equal(fb.globals_info.deleted.length, 0, "No globals should have been deleted");
  };

  tests[0].timeout = 0;
  tests[0].followup = function() {};

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

