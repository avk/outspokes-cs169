/*********************************************************/

(function() {
  var news = [];
  var deleted = [];
  var trigger;

  function indexOfIn(x, array) {
    for (var i = 0; i < array.length; i++) {
      if (array[i] == x) {
        return i;
      }
    }
    return -1;
  }

  for (var i in pre) {
    trigger = false;
    for (var j in window) {
      if (j == pre[i]) {
        trigger = true;
        break;
      }
    }
    if (trigger) {
      continue;
    }
    deleted.push(pre[i]);
  }

  for (var i in window) {
    trigger = false;
    for (var j in pre) {
      if (i == pre[j]) {
        trigger = true;
        break;
      }
    }
    if (trigger) {
      continue;
    }
    news.push(i);
  }

  fb.globals_info = {
    "news": news,
    "deleted": deleted
  };
})();

/*********************************************************/


