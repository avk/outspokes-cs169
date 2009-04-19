  var $ = fb.$;

  fb.Interface.comment = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      comment_id_format   : /comment_\d+/i,
      comment_id          : function(id) {
        return (this.comment_id_format.test(id)) ? id : 'comment_' + parseInt(id);
      },
      consensus_wrapper         : function(id) {
        return "consensus_on_comment_" + parseInt(id);
      },
      agree_with                : function(id) {
        return "agree_with_comment_" + parseInt(id);
      },
      disagree_with             : function(id) {
        return "disagree_with_comment_" + parseInt(id);
      },
      agree_bg_color      : '#6F5',
      disagree_bg_color   : 'red',
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
      }
    };
    
    this.buildCommentForm = function (id, target) {
      var formHTML = '<a id="refresh" href="#">refresh</a>\
        <form id="comment_form" name="newcomment" onsubmit="return false;">';
    	if (fb.env.pub_page) {
    	  formHTML += '<label for="fb.name.input">Name:</label>\
    	    <input id="fb.name.input" type="text" name="name" size="20" /><br />'
    	}
    	formHTML += 'Comment:<br />\
      <textarea name="content" cols="30" rows="5" /><br />\
      <input type="submit" value="Submit" />&nbsp;&nbsp;<span>Select target</span>\
      <input type="hidden" value="' + target + '" name="target" />\
      </form>'
      return $('<div id="' + id + '"></div>').append(formHTML);
    }
    
    this.comments = $('<div id="comment_list"></div>');
    this.form = this.buildCommentForm(this.dom.comment_form, "html");
    this.form.find("a").click(function(){fb.Feedback.get("render");});
    this.form.find("form").submit(function() { 
      var name = null;
      if (fb.env.pub_page) {
        name = this.name.value;
      }
      fb.Comment.post(this.content.value, this.target.value, name);
    });
    this.form.find("span").mouseup(select_target);
    self.widget_content.append(this.comments);
    self.widget_content.append(this.form);
    
    this.consensus = {
      dom   : this.dom,
      _opinion: function(c_id, color) {
        var comment = null;
        if (typeof c_id == "string") {
          comment = $('#' + this.dom.comment_id(c_id));
        } else {
          comment = c_id;
        }
        comment.css({ 'background-color' : color });
      },
      agree: function(c_id) {
        this._opinion(c_id, this.dom.agree_bg_color);
      },
      disagree: function(c_id) {
        this._opinion(c_id, this.dom.disagree_bg_color);
      },
      build : function(c, markup) {
        if (c.opinion !== "") { // this invitee has voted on this comment
          if (c.opinion === 'agreed') {
            this.agree(markup);
          } else if (c.opinion == 'disagreed') {
            this.disagree(markup);
          } else if (c.opinion == 'mine') {
          }
        } else { // this invitee should be allowed to vote on this comment
          var consensus_div = $('<div></div>');
          var agree = this.button(c, 'agree');
          var disagree = this.button(c, 'disagree');
          
          consensus_div[0].setAttribute("id", this.dom.consensus_wrapper(c.feedback_id));
          consensus_div.append(agree);
          consensus_div.append(disagree);
          markup.append(consensus_div);
        }
        return markup;
      },
      button : function(c, action) {
        var button = $('<button type="button">' + action + '</button>');
        button[0].setAttribute("id", eval('this.dom.' + action + '_with(c.feedback_id)'));
        button.click(function() { eval('c.' + action + '()'); });
        return button;
      }
    };
    
    this.reply = {
      // for easier, scoped dom references below
      dom             : this.dom,
      parent          : this,
      // adds a reply to another comment in the interface
      render          : function(c) {
        var rtn = c.build;
        var parent = document.getElementById(c.target);
        var parent_border = null;
        if (parent && parent.style && parent.style.borderLeftWidth) {
          parent_border = parseInt(parent.style.borderLeftWidth, 10);
        } else {
          parent_border = 0;
        }
        new_border = parent_border + 5 + "px";
        rtn.css({ 'border-left': new_border + ' solid black' });
        $(this.dom.parent_reply_list(c.target)).append(rtn);
      },
      // constructs a "reply" link
      buildLink       : function(c_id) {
        var replyLink = $('<a href="#" class="' + this.dom.reply_links + '">&raquo; reply</a>');
        replyLink.click(function(){ fb.i.comment.reply.start(c_id); });
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
        var form = this.parent.buildCommentForm(reply_form, c_id);
        form.find("form").append('<input type="reset" value="Cancel" />');
        form.find("form").submit(function() { 
          var name = null;
          if (fb.env.pub_page) {
            name = this.name.value;
          }
          fb.Comment.post(this.content.value, this.target.value, name);
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
    };
    
    this.build = function (c) {
      var rtn = $('<div></div>').css('width','100%');
	  var c_id = this.dom.comment_id(c.feedback_id);
   	  rtn[0].setAttribute('id', c_id);
      rtn.append(c.name + "<br />");
      rtn.append(c.content + "<br />");
      rtn.append(new Date(c.timestamp) + "<br />");
      rtn = this.consensus.build(c, rtn);
      // set up reply actions
      rtn.append(this.reply.buildLink(c_id));
      rtn.append("<hr style='width:80%' />");
      rtn.append('<div id="' + this.dom.reply_list(c_id) + '"></div>');
      
      // bind the comment to its target
      if (c.target != "html" && c.target != "html > body" && !c.isReply()) {
        var tmp = $(c.target)[0];
        tmp = highlight_target(tmp);
        rtn.hover(tmp[0], tmp[1]);
      }
      return rtn;
    };
    
    this.render = function(c) {
      if (c.isReply()) {
        this.reply.render(c);
      } else {
        this.comments.append(c.build);
      }
    };
    
    this.post_failed = function(c){};
    
    this.remove = function(c){
      c.build.remove();
    };
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
