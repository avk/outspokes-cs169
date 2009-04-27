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
    	formHTML += '<div id="outspokes_form_header"><span>Comment:</span></div><textarea name="content" cols="30" rows="5" />' +
          '<div id="outspokes_form_buttons"><input type="submit" value="Submit" /></div>&nbsp;&nbsp;' +
          '<input type="hidden" value="' + target + '" name="target" />' +
          '</form>';
      return $('<div id="' + id + '"></div>').append(formHTML);
    };

    this.form = this.buildCommentForm(this.dom.comment_form, "html");
    var target_button = $('<img id="outspokes_target_button src=' + fb.env.target_address + '/>');
//    target_button.css('float', 'right').css('margin-top', '5px');
    target_button.click(select_target);
    this.form.find("#outspokes_form_header").prepend(target_button);
    this.comments = $('<div id="comment_list"></div>');
    this.form.find("a").click(function(){fb.Feedback.get();});
    this.form.find("form").submit(function() { 
      var name = null;
      if (fb.env.pub_page) {
        name = this.name.value;
        this.name.value = "";
      }
      fb.Comment.post(this.content.value, this.target.value, name);
      this.content.value = "";
      fb.i.comment.reset_target();
    });
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
          consensus_div[0].setAttribute("class", 'cns_buttons');

          if (_fb.admin()) {
            consensus_div.append($('<span class="agreed">' + c.agreed + ' agreed</span><br />'));
            consensus_div.append($('<span class="disagreed">' + c.disagreed + ' disagreed</span><br />'));
          } else {
            consensus_div.append(agree);
            consensus_div.append(disagree);
          }
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
    		var replyButtons = $('.' + this.dom.reply_links);
        replyButtons.each(function(i) {
          var button = $(this)
          if (button.attr("disabled")) { 
            button.removeAttr("disabled"); 
          } else { 
             button.attr("disabled", "disabled"); 
          }
        });

        $('#' + this.dom.cform).toggle();
      },
      // start replying to a comment
      start           : function(c_id) {
        fb.i.comment.reset_target();
        this.setupInterface();
        var backend_id = c_id.match(/comment_(\d+)/i)[1];
        // show the reply form
        var reply_form = this.dom.reply_form(c_id);
        var form_container = this.parent.buildCommentForm(reply_form, c_id);
        var form = form_container.find("form");
        var reset_button = $('<input type="reset" value="Cancel" class="second_button" />');
        form.find('#outspokes_form_buttons').prepend(reset_button);
        form.find('#outspokes_form_header span').html("Reply to <strong>" + fb.Feedback.all[backend_id].name + "</strong>:");
    		form.attr('class','reply');
        form.submit(function() { 
          var name = null;
          if (fb.env.pub_page) {
            name = this.name.value;
          }
          fb.Comment.post(this.content.value, this.target.value, name);
          fb.i.comment.reply.finish(reply_form);
        });
        
        reset_button.click(function(){ 
          fb.i.comment.reply.cancel(reply_form);
        });
        //$('#' + this.dom.reply_list(c_id)).before(form);
        $('#' + this.dom.comment_form).append(form_container);
        
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
		
		  bar.append('<span class="cmt_date">' + fb.get_timestamp(c.timestamp) + '</span>');
		
  		bar.click(function(){ cmt.toggle(); });
    
  		rtn.append(bar);
  		rtn.append(cmt);
    	cmt.append('<p class="cmt_text">' + c.content + '</p>');

  		cmt = this.consensus.build(c, cmt);

      //admin only delete
      if (_fb.admin()) {
        var deleteCmt = $('<button type="button" id="delete_cmt">delete</button>');
        deleteCmt.click(function() {
          if (c.__unHover) {
            c.__unHover();
          }
          c.remove();
        });
        cmt.append(deleteCmt);
      }

      // set up reply actions
      cmt.append(this.reply.buildLink(c_id));
      cmt.append('<div id="' + this.dom.reply_list(c_id) + '"></div>');
      
      // bind the comment to its target
      if (c.target != "html" && c.target != "html > body" && !c.isReply()) {
        var tmp = $(c.target);
        tmp = highlight_target(tmp.get(0));
        c.__unHover = tmp[1];
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
    
    this.reset_target = function() {
      // Un-highlight element
      var old_element = $(fb.i.comment.form.find("input[name='target']").attr("value"));
      old_element.css('outline', old_element.get(0)._old_style);
      delete old_element.get(0)["_old_style"];
      // Reset form target
      fb.i.comment.form.find("input[name='target']").attr("value","html");
      // Remove orange
      $('#outspokes_target_button').css("background-color", "");
    };
    
    this.visit_all_replies = function(c, fn) {
      var c = $(c);
      var parent = this;
//      var this_id = c.attr('id').match(/comment_(\d+)/i)[1];
      c.find('#' + this.dom.reply_list(c.attr('id'))).children().each(function() {
        var this_id = this.id.match(/comment_(\d+)/i)[1];
        fn(fb.Feedback.all[this_id]);
        parent.visit_all_replies(this, fn);
      });
    };
    
  };
  
  function select_target() {
    $(this).get(0).value = "Change target";
    // Filter out all elements that are part of Outspokes
    var filter = "body *:not(#outspokes *, #outspokes, #outspokes_admin_panel," + 
      " #outspokes_admin_panel *, #outspokes_overlay, #outspokes_overlay *)";
    var page_elements = $(filter);
    page_elements.bind('mouseup.elem_select', function (e) {
      fb.i.comment.form.find("input[name='target']").attr("value",fb.getPath(e.target));
      e.target.__marked = true;
      $("body *").unbind(".elem_select");
      e.stopPropagation();
      $('#outspokes_target_button').css("background-color", "orange");
    });
    // Attach to every element _inside_ of body
    page_elements.bind("mouseenter.elem_select", function (e) {
      if ("_old_style" in $(e.target).parent().get(0)) {
        $(e.target).parent().eq(0).css('outline', $(e.target).parent().get(0)._old_style);
        delete $(e.target).parent().get(0)["_old_style"];
      }
      e.target._old_style = $(e.target).css('outline')
      $(e.target).css('outline','green solid 2px')
      e.stopPropagation();
    });
    page_elements.bind("mouseleave.elem_select", function (e) {
      if (! ("__marked" in e.target)) {
        $(e.target).css('outline', e.target._old_style);
        delete e.target["_old_style"];
        e.stopPropagation();
      }
    });
  }
  
  function highlight_target(el_dom) {
    el = $(el_dom);
//    var par = el.wrap("<div></div>").parent();
    var old_style = el.css('outline')
    over = function() {
      el.css('outline','green solid 2px');
    }
    out = function() {
      el.css('outline-style', old_style);
    }
    return [over, out];
  }
