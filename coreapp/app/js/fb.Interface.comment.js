(function(fb){
  var $ = fb.$;
  
  fb.Interface.comment = function (t) {
    this.build = function (c) {
      var rtn = $.div().css('width','100%');
      rtn.append("<div>" + c.name + "</div><br />");
      rtn.append(c.content + "<br />");
      rtn.append(Date(c.timestamp) + "<br />");
      rtn.append("<hr style='width:80%' /><br />");
      if (c.target != "html" && c.target != "html > body") {
        var tmp = $(c.target)[0];
        tmp = highlight_target(tmp);
        rtn.hover(tmp[0], tmp[1]);
      }
      return rtn;
    }
    
    this.render = function(c) {
      t.main_window.append(c.build);
    }
    
    this.post_failed = function(c){}
    
    this.remove = function(c){}
  }
  
  function highlight_target(el) {
    el = $(el);
    var par = el.wrap("<div></div>").parent();
    over = function() {
      par.css('outline','green solid 3px');
    }
    out = function() {
      par.css('outline-style','none');
    }
    return [over, out];
  }
})(fb_hash);
