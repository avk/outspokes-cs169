if (window.location.href.search(/noglobals/) === -1) {
  var url = window.location.href;
  if (url.search(/\?/) != -1) {
    if (url.charAt(url.length -1) != "&") {
      window.location.href = url + "&noglobals";
    } else {
      window.location.href = url + "noglobals";
    }
  } else {
    window.location.href = url + "?noglobals";
  }
}

(function() {
  var trigger = false;
  var old = null;
  if (typeof window['pre'] !== "undefined") {
    old = window['pre'];
    trigger = true;
  }
  window['pre'] = [];
  for (var i in window) {
    pre.push(i);
  }
  if (trigger) {
    pre._pre = old;
  }
})();

/*********************************************************/


