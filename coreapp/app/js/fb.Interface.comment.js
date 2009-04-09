(function(fb){
  var $ = fb.$;

  fb.Interface.comment = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      comment_id_format   : /comment_\d+/i,
      comment_id          : function(id) {
        return (this.comment_id_format.test(id)) ? id : 'comment_' + parseInt(id);
      },
      comment_form        : "new-comment",
      reply_links         : "comment-reply",
      reply_form          : function(id) {
        return this._prefix(id) + '_reply';
      },
      reply_list          : function(id) {
        return this._prefix(id) + '_replies';
      },
      parent_reply_list   : function(parent_id) {
        return '#' + this.comment_id(parent_id) + ' #' + this.reply_list(parent_id);
      },
      _prefix             : function(id) {
        return (this.comment_id_format.test(id)) ? id : this.comment_id(id);
      },
    };
    
    this.comments = $('<div></div>');
    this.form = $('<div id="' + this.dom.comment_form + '"></div>').append( 
     '<a href="#">Refresh comments</a>\
      <form name="newcomment" onsubmit="return false;">\
        Comment:<br />\
        <textarea name="content" cols="30" rows="5" /><br />\
        <input type="submit" value="Submit" />&nbsp;&nbsp;<span>Select target</span>\
        <input type="hidden" value="html" name="target" />\
      </form>');
    this.form.find("a").click(function(){fb.Feedback.get("render")});
    this.form.find("form").submit(function() { 
      fb.Comment.post(this.content.value, this.target.value);
    });
    this.form.find("span").mouseup(select_target);
    self.main_window.append(this.comments);
    self.main_window.append(this.form);
    
    this.reply = {
      // for easier, scoped dom references below
      dom             : this.dom,
      // adds a reply to another comment in the interface
      render          : function(c) {
        var rtn = c.build;
        var parent = document.getElementById(c.target);
        if (parent && parent.style && parent.style.borderLeftWidth) {
          var parent_border = parseInt(parent.style.borderLeftWidth);
        } else {
          var parent_border = 0;
        }
        new_border = parent_border + 5 + "px";
        rtn.css({ 'border-left': new_border + ' solid black' });
        $(this.dom.parent_reply_list(c.target)).append(rtn);
      },
      // constructs a "reply" link
      buildLink       : function(c_id) {
        var replyLink = $('<a href="#" class="' + this.dom.reply_links + '">&raquo; reply</a>');
        replyLink.click(function(){ fb.i.comment.reply.start(c_id) })
        return replyLink;
      },
      // toggles the non-replying interface
      setupInterface  : function() {
        $('.' + this.dom.reply_links).toggle();
        $('#' + this.dom.comment_form).toggle();
      },
      // start replying to a comment
      start           : function(c_id) {
        this.setupInterface();
        
        // show the reply form
        var reply_form = this.dom.reply_form(c_id);
        var form = $('<div id="' + reply_form + '"></div>').append(
         '<form name="new-reply-comment" onsubmit="return false;">\
            Reply:<br />\
            <textarea name="content" cols="30" rows="5" /><br />\
            <input type="hidden" value="' + c_id + '" name="target" />\
            <input type="submit" value="Reply" />\
            <input type="reset" value="Cancel" />\
          </form>');
        
        form.find("form").submit(function() { 
          fb.Comment.post(this.content.value, this.target.value);
          fb.i.comment.reply.finish(reply_form);
        });
        
        form.find("input[type='reset']").click(function(){ 
          fb.i.comment.reply.cancel(reply_form);
        });
        $('#' + this.dom.reply_list(c_id)).before(form);
        
        form.find("textarea[name='content']").focus();
        // would be nice to also scroll to the comment form here like:
        // http://plugins.jquery.com/project/ScrollTo
      },
      // cancel a reply in progress
      cancel          : function(reply_form) {
        $('#' + reply_form).remove();
        this.setupInterface();
      },
      // finish replying to a comment
      finish          : function(reply_form) {
        this.cancel(reply_form);
      }
    }
    
    this.build = function (c) {
      var c_id = this.dom.comment_id(c.feedback_id);
      var rtn = $('<div id="' + c_id + '"></div>').css('width','100%');
      rtn.append(c.name + "<br />");
      rtn.append(c.content + "<br />");
      rtn.append(new Date(c.timestamp) + "<br />");
      
      // set up reply actions
      rtn.append(this.reply.buildLink(c_id));
      rtn.append("<hr style='width:80%' />");
      rtn.append('<div id="' + this.dom.reply_list(c_id) + '"></div>');
      
      // bind the comment to it's target
      if (c.target != "html" && c.target != "html > body" && !c.isReply()) {
        var tmp = $(c.target)[0];
        tmp = highlight_target(tmp);
        rtn.hover(tmp[0], tmp[1]);
      }
      return rtn;
    }
    
    this.render = function(c) {
      if (c.isReply()) {
        this.reply.render(c);
      } else {
        this.comments.append(c.build);
      }
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
