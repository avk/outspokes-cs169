(function(fb){
  var $ = fb.$;
  
  fb.Interface.comment = function (self) {
    this.comments = $('<div></div>');
    this.form = $('<div></div>').append(
     '<a href="#">Refresh comments</a>\
      <form name="newcomment" onsubmit="return false;">\
        Comment:<br />\
        <textarea name="content" cols="40" rows="5" /><br />\
        <input type="submit" value="Submit" />&nbsp;&nbsp;<span>Select target</span>\
        <input type="hidden" value="html" name="target" />\
      </form>');
    this.form.find("a").click(function(){fb.Feedback.get("render")});
    this.form.find("form").submit(fb.Comment.post);
    this.form.find("span").mouseup(select_target);
    self.main_window.append(this.comments);
    self.main_window.append(this.form);
    
    this.build = function (c) {
      var rtn = $('<div></div>').css('width','100%');
      rtn.append(c.name + "<br />");
      rtn.append(c.content + "<br />");
      rtn.append(new Date(c.timestamp) + "<br />");
      rtn.append("<hr style='width:80%' />");
      if (c.target != "html" && c.target != "html > body") {
        var tmp = $(c.target)[0];
        tmp = highlight_target(tmp);
        rtn.hover(tmp[0], tmp[1]);
      }
      return rtn;
    }
    
    this.render = function(c) {
      this.comments.append(c.build);
    }
    
    this.post_failed = function(c){}
    
    this.remove = function(c){
      c.build.remove();
	}
  }
  
  function select_target() {
    $(this).html("Change target");
    $(document.body).one('click', function (e) {
      fb.i.comment.form.find("input[name='target']").attr("value",fb.getPath(e.target));
    });
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
