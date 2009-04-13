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

  if (news.length > 0) {
    console.error("Extra global variables were created:", news);
  } else {
    console.info("No extra global variables were created.");
  }

  if (deleted.length > 0) {
    console.error("Ummmm...  Somehow we deleted some global variables:", deleted);
  } else {
    console.info("No global variables were deleted.");
  }
})();

var $ = fb.$;
var jQuery = fb.$;

/*********************************************************/


