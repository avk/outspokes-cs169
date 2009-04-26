  var $ = fb.$;

  fb.Interface.comment = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      comment_id_format   : /comment_\d+/i,
      comment_id          : function(id) {
        return (this.comment_id_format.test(id)) ? id : 'comment_' + parseInt(id);
      },
      number_from_id            : function(dom_id) {
        return parseInt(dom_id.match(/comment_(\d+)/i)[1]);
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
    	cform       				: "comment_form",
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
	/*'<a id="refresh" href="#">refresh</a>' why is refresh in the comment form? */
      var formHTML = '<form id="comment_form" name="newcomment" onsubmit="return false;">';
    	if (fb.env.pub_page) {
    	  formHTML += '<label for="fb.name.input">Name:</label>' +
    	    '<input id="fb.name.input" type="text" name="name" size="20" /><br />'
    	}
    	formHTML += 'Comment:<br /><textarea name="content" cols="30" rows="5" /><br />' +
          '<input type="submit" value="Submit" />&nbsp;&nbsp;<span>Select target</span>' +
          '<input type="hidden" value="' + target + '" name="target" />' +
          '</form>'
      return $('<div id="' + id + '"></div>').append(formHTML);
    };
    
    this.comments = $('<div id="comment_list"></div>');
    this.form = this.buildCommentForm(this.dom.comment_form, "html");
    this.form.find("a").click(function(){fb.Feedback.get();});
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
    			//admin's consensus statistics
    			var consensus_count = $('<span>xxx agreed</span><br /><span>xxx disagreed</span>');
          
          consensus_div[0].setAttribute("id", this.dom.consensus_wrapper(c.feedback_id));
          consensus_div[0].setAttribute("class", 'cns_buttons');
          consensus_div.append(agree);
          consensus_div.append(disagree);
		
      		//if admin
      		//consensus_div.append(consensus_count);
          markup.append(consensus_div);
        }
        return markup;
      },
      button : function(c, action) {
        var button = $('<button type="button">' + action + '</button><br />');
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
        new_border = parent_border + 1 + "px";
        rtn.css({ 'border-left': new_border + ' solid black' });
        $(this.dom.parent_reply_list(c.target)).append(rtn);
      },
      // constructs a "reply" link
      buildLink       : function(c_id) {
        var replyLink = $('<button type="button" class="' + this.dom.reply_links + '">&raquo; reply</button>');
		
        replyLink.click(function(){ fb.i.comment.reply.start(c_id); });
        return replyLink;
      },
      // toggles the non-replying interface
      setupInterface  : function() {
    		var replyButton = $('.' + this.dom.reply_links);
    		if (replyButton.attr("disabled")) { 
    		  replyButton.attr("disabled", "false"); 
  		  } else { 
  		    replyButton.attr("disabled", "true"); 
		    }
        $('#' + this.dom.cform).toggle();
      },
      // start replying to a comment
      start           : function(c_id) {
        this.setupInterface();

        // show the reply form
        var reply_form = this.dom.reply_form(c_id);
        var form = this.parent.buildCommentForm(reply_form, c_id);
        form.find("form").append('<input type="reset" value="Cancel" />');
    		form.find("form").attr('class','reply');
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
        //$('#' + this.dom.reply_list(c_id)).before(form);
        $('#' + this.dom.comment_form).append(form);
        
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
  		var bar = $('<div class="cmt_bar"></div>');
  		var cmt = $('<div></div>');
  		rtn[0].setAttribute('id', c_id);
	
  		bar[0].setAttribute('id', 'bar_' + c_id);
  		cmt[0].setAttribute('id', 'body_' + c_id);
  		bar.append('<span class="commenter_name">'+ c.name +'</span>');
		
  		bar.append('<span class="cmt_date">' + new Date(c.timestamp) + '</span>');

		
  		bar.click(function(){ cmt.toggle(); });
    
  		rtn.append(bar);
  		rtn.append(cmt);
    	cmt.append('<p class="cmt_text">' + c.content + '</p>');

  		cmt = this.consensus.build(c, cmt);

  		//admin only delete
  		var deleteCmt = $('<button type="button" id="delete_cmt">delete</button>');
  		cmt.append(deleteCmt);
		
      // set up reply actions
      cmt.append(this.reply.buildLink(c_id));
      cmt.append('<div id="' + this.dom.reply_list(c_id) + '"></div>');
      
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
    
    this.post_failed = function(c) {};
    
    this.remove = function(c){
      c.build.remove();
    };
    
    this.sort_comments = function(method) {
      var posts = this.comments.children();
      this.comments.empty();
      posts.sort(method(this));
      this.comments.append(posts);
    };

    this.newest_sorter = function(self) {
      return function(a, b) {
        var a_id = self.dom.number_from_id(a.id);
        var b_id = self.dom.number_from_id(b.id);
        return (a_id - b_id);
      };
    };

    this.oldest_sorter = function(self) {
      return function(a, b) {
          var a_id = self.dom.number_from_id(a.id);
          var b_id = self.dom.number_from_id(b.id);
          return (fb.Feedback.all[b_id].timestamp - fb.Feedback.all[a_id].timestamp);
      };
    };
    
    this.sort_by_newest = function() {
      this.sort_comments(this.newest_sorter);  
    };
    
    this.sort_by_oldest = function() {
      this.sort_comments(this.oldest_sorter);  
    };
    
  };

  
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
      par.css('outline','green solid 2px');
    }
    out = function() {
      par.css('outline-style','none');
    }
    return [over, out];
  }
