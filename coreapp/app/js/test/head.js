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

var jQuery, $;

/*********************************************************/


