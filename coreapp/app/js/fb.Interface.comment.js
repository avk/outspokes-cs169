  /* The following for JSLint: */
  /*global fb, _fb, document */
  
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
      agreed              : 'outspokes_agreed',
      disagreed           : 'outspokes_disagreed',
      comment_form        : "outspokes_new_comment",
      reply_links         : "comment-reply",
      cform               : "outspokes_comment_form",
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
      var formHTML = '<form id="outspokes_comment_form" name="newcomment" onsubmit="return false;">';
    	var form_header = '<div id="outspokes_form_header"><span>Comment</span></div><div id="outspokes_form_wrapper"><textarea name="content" rows="7" /></div>';
      formHTML += form_header;
      var form_buttons =  '<div id="outspokes_form_buttons">'
      if ( !_fb.admin() ) {
        form_buttons += '<div id="outspokes_private_wrapper"><input type="checkbox" id="isPrivate" name="isPrivate" value="true">' + 
                        '&nbsp;<label for="isPrivate" title="Only the person who asked for your feedback will see it.">Private</label></div>';
      } else {
        form_buttons += '<input type="hidden" value="false" name="isPrivate" />'
      }
      form_buttons += '<input class="outspokes_button" type="reset" value="Clear" />' +
          '<input class="outspokes_button" type="submit" value="Post" /></div>';
      formHTML += form_buttons;
      var form_finish = 
          '<input type="hidden" value="' + target + '" name="target" />' +
          '</form>';
      formHTML += form_finish; 
      return $('<div id="' + id + '"></div>').append(formHTML);
    };

    this.form = this.buildCommentForm(this.dom.comment_form, "html");

    // TARGETING ///////////////////////

    var target_button = $('<img class="outspokes_target_button" src="' + fb.env.target_address + '" title="Target an element" />');
    target_button.click(function() {
      $(this)[0].value = "Change target";
      fb.i.comment.reset_target();
      $("#outspokes_form_header").find('span').text("Pick a target for your comment");
      fb.select_target(function(e) {
        fb.i.comment.form.find("input[name='target']").attr("value", fb.getPath(e.target));
        $(e.target).removeClass("outspokes_currently_hovering");
        $(e.target).addClass("outspokes_selected_page_element");
        $('.outspokes_target_button').addClass('outspokes_target_set');
        $('#outspokes_form_header').find('span').text('Targeted Comment');
      }, function(e) {
        $(e.target).addClass("outspokes_currently_hovering");
      }, function(e) {
        $(e.target).removeClass("outspokes_currently_hovering");
      });
    });

    this.form.find("#outspokes_form_header").prepend(target_button);
    this.comments = $('<div id="outspokes_comment_list"></div>');
    
    // default view for when there's no comments
    this.no_comments = $('<div id="outspokes-no-comments"></div>');
    this.no_comments.append('<span class="outspokes-no-comments-message">Nothing yet</span><br />');
    
    
    var call_to_action = $('<span class="outspokes-no-comments-action"></span>');
    if (_fb.admin()) {
      call_to_action.append("Have you ");
      invite_link = $('<a href="#">invited folks</a>');
      invite_link.click(function() {
        // open up the admin panel and go to the commenters tab
        fb.i.admin_panel.set_to_commenters();
        fb.i.hide_widget();
        fb.i.admin_panel.show();
      });
      call_to_action.append(invite_link);
      call_to_action.append('?');
    } else { // commenter
      comment_link = $('<a href="#">Be the first to comment!</a>');
      comment_link.click(function() {
        $('#outspokes_form_wrapper textarea').focus();
      });
      call_to_action.append(comment_link);
    }
    
    this.no_comments.append(call_to_action);
    this.comments.append(this.no_comments);
    
    this.form.find("a").click(function(){fb.Comment.get();});
    this.form.find("form").submit(function() { 
      fb.Comment.post(this.content.value, this.target.value, this.isPrivate.checked);
      this.content.value = "";
      fb.i.comment.reset_target();
    });
    // Cancel button
    var textarea = this.form.find('textarea')
    this.form.find("input[type='reset']").click(function() {
      textarea.text("");
      fb.i.comment.reset_target();
    });
    self.widget_content.append(this.comments);
    self.widget_content.append(this.form);
    
    this.consensus = {
      dom   : this.dom,
      _opinion : function(c_id, consensus_class) {
        var comment = null;
        if (typeof c_id == "string") {
          comment = $('#' + this.dom.comment_id(c_id));
        } else {
          comment = c_id;
        }
        comment.addClass(consensus_class);
      },
      agree: function(c_id) {
        this._opinion(c_id, this.dom.agreed);
      },
      disagree: function(c_id) {
        this._opinion(c_id, this.dom.disagreed);
      },
      build : function(c, markup) {
        if (c.opinion !== "" && !_fb.admin()) { // this invitee has voted on this comment
          if (c.opinion === 'agreed') {
            this.agree(markup);
          } else if (c.opinion == 'disagreed') {
            this.disagree(markup);
          } else if (c.opinion == 'mine') {
          }
        } else if (c.isPrivate){ //comment is private, don't display any of this
          return "";
        } else { // this invitee should be allowed to vote on this comment
          var consensus_div = $('<div></div>');
          var agree = this.button(c, 'agree').addClass('outspokes_agree');
          var disagree = this.button(c, 'disagree').addClass('outspokes_disagree');
          
          agree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});
          disagree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});
          
          consensus_div[0].setAttribute("id", this.dom.consensus_wrapper(c.feedback_id));
          consensus_div[0].setAttribute("class", 'outspokes_cns_buttons');

          if (_fb.admin()) {
            consensus_div.append($('<span class="outspokes_agreed">' + c.agreed + '&nbsp;agreed,</span>&nbsp;'));
            consensus_div.append($('<span class="outspokes_disagreed">' + c.disagreed + '&nbsp;disagreed</span>'));
          } else {
            consensus_div.append(agree);
            consensus_div.append(disagree);
          }
          return consensus_div;
        }
        return "";
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
        var parent_comment = fb.Comment.all[this.dom.number_from_id(c.target)];
        parent_comment.num_replies++;
        if (parent_comment.num_replies != 1) {
          parent_comment.build.find('.outspokes_reply_count:eq(0)').html(parent_comment.num_replies + " replies");
        }
        else {
          parent_comment.build.find('.outspokes_reply_count:eq(0)').html(parent_comment.num_replies + " reply")
        }
        
        $(this.dom.parent_reply_list(c.target)).append(rtn);
      },
      // constructs a "reply" link
      buildLink       : function(c_id) {
        var replyLink = $('<button type="button" class="' + this.dom.reply_links + '">reply&nbsp;&raquo;</button>');
        replyLink.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});
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
        form.find('#outspokes_form_header span').html("Reply to <strong>" + fb.Comment.all[backend_id].name + "</strong>");
        form.find('#outspokes_form_buttons').html(
          '<input class="outspokes_button" type="reset" value="Cancel" />' +
          '<input class="outspokes_button" type="submit" value="Reply" />');
        form.attr('class','reply');
        form.submit(function() { 
          fb.Comment.post(this.content.value, this.target.value, false);
          fb.i.comment.reply.finish(reply_form);
        });
        var cancel_button = form.find('input[type="reset"]');
        cancel_button.unbind('click');
        cancel_button.click(function(){ 
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
  		var c_id = this.dom.comment_id(c.feedback_id);
      var rtn = $('<div></div>');   // comment-block
      rtn.attr('id', c_id).addClass('outspokes_thread');
      
      var bar = $('<div></div>').addClass('outspokes_cmt_bar');   // bar
      bar.attr('id', 'bar_' + c_id);
      bar.append($('<span></span>').addClass('outspokes_commenter_name').append(c.name));
      if (c.isPrivate) {
        bar.append($('<span> &mdash; private</span>').addClass('outspokes_private'));
      } 
      
      var link_span;
      // Reply link
      if (c.isReply()) {
        link_span = $('<span>in reply to </span>').addClass("outspokes_reply_to_text");
        var link = $('<a>comment by ' + c.parent_comment().name + '</a>');
        link_span.append(link);
        // Go to parent thread when clicking on parent link
        link.click(function(e) {
          $("#outspokes_comments_filter").val("Newest first");
          fb.i.comment.sort_by_newest();
          // THIS IS MAJORLY LAME, BUT I DUNNO HOW TO AVOID IT:
          setTimeout(function() {
            fb.$("#outspokes_comment_list").scrollTo(c.parent_comment().build, 700);
          }, 300);
          e.stopPropagation();
          return false;
        });
        bar.append(link_span);
      }
      
      // snippet
      var snippet_length = 80;
      var snippet = c.content.replace(/<br \/>/g, '\n');
      if (snippet.length > snippet_length) { // shorten if needed
        snippet = $.trim(snippet.substring(0, snippet_length)).replace(/\n/g, '&nbsp;&nbsp;&nbsp;') + '...';
      }
      bar.append($('<span></span>').addClass('outspokes_snippet').append(snippet).hide());
      
      //Number of replies
      
      bar.append($('<span></span>').addClass('outspokes_reply_count').append('0 replies').hide());
      
      var timestamp_close = $('<span></span>').addClass('outspokes_cmt_date').append(fb.get_timestamp(c.timestamp))
      
      
      if (_fb.admin()) {
        var deleteCmt = $('<span title="Delete this comment">X</span>').addClass('outspokes_cmt_delete_X');

        deleteCmt.click( function(e) { e.stopPropagation(); } );

        deleteCmt.click(function() {
          if (c.__unHover) {
            c.__unHover();
          }
          var answer = confirm("Are you sure you want to delete the comment? All of its replies will also be deleted.");
          if (answer){
              c.destroy();
          }
        });
        
        timestamp_close.append(deleteCmt);
      }
      bar.append(timestamp_close);
      var content = $('<div></div>').addClass('outspokes_cmt_content');//.attr('id', c_id);

      var options = $('<div></div>').addClass('outspokes_options');

      var tmp = this.consensus.build(c, bar);
      options.append(tmp);
      options.append(this.reply.buildLink(c_id));
      
      content.append($('<div></div>').addClass('cmt_text').append(c.content));
      content.append(options);

      var replies = $('<div></div>').attr('id', this.dom.reply_list(c_id)).addClass('outspokes_replies');
      var comment = $('<div></div>').addClass('comment');
      comment.append(bar).append(content);
      
      rtn.append(comment).append(replies);
      bar.click(function() {
        
        function collapse(cmt) {
          // console.log("collapsing...");
          $(cmt).parent().addClass("outspokes_collapsed");
          $(cmt).parent().parent().find('div.outspokes_cmt_content:eq(0)').hide();
          $(cmt).parent().find('.outspokes_cmt_date:eq(0)').hide();
          $(cmt).parent().find('.outspokes_snippet:eq(0), .outspokes_reply_count:eq(0)').show();
        };
        
        function uncollapse(cmt) {
          // console.log("uncollapsing...");
          $(cmt).parent().removeClass("outspokes_collapsed");
          $(cmt).parent().parent().find('div.outspokes_cmt_content:eq(0)').show();
          $(cmt).parent().find('.outspokes_cmt_date:eq(0)').show();
          $(cmt).parent().find('.outspokes_snippet:eq(0), .outspokes_reply_count:eq(0)').hide();
        };
        
        // toggle me
        if ($(this).parent().hasClass("outspokes_collapsed")) {
          uncollapse(this);
        } else {
          collapse(this);
        }
        
        // toggle my replies
        var p = $(this).parent();
        var parent = $(this).parent().parent();
        if (parent.hasClass("outspokes_thread")) {
          var replies = "#" + fb.i.comment.dom.reply_list(c.feedback_id);
          parent.find(replies).find('.outspokes_cmt_bar').each(function() {
            // parent collapsed, i'm not
            if (p.hasClass("outspokes_collapsed") && 
                ! $(this).parent().hasClass("outspokes_collapsed")) { 
              collapse(this);
            }
            
            // parent collapsed, i am
            // do nothing
            
            // parent expanded, i'm not
            if (!p.hasClass("outspokes_collapsed") &&
                $(this).parent().hasClass("outspokes_collapsed")) {
              uncollapse(this);
            }
            
            // parent expanded, i am
            // do nothing
          });
        }
      });
      
      // Returns a DOM element with a missing target message
      this.missing_target = function() {
        return $('<div></div>').addClass('outspokes_missing_target').text("This comment refers to an element that no longer exists on this page.");
      }
      
      // bind the comment to its target
      if (c.target != "html" && c.target != "html > body" && !c.isReply()) {
        tmp = $(c.target);
        if (tmp.size() === 0) {
          rtn.find('.cmt_text').before( this.missing_target() );
        } else {
          // Render missing_target message when targeted element is removed
          tmp[0].addEventListener("DOMNodeRemoved", function(e) {
            rtn.find('.cmt_text').before( fb.i.comment.missing_target() );
          }, true);
          tmp = highlight_target(tmp.get(0));
          c.__unHover = tmp[1];
          rtn.hover(tmp[0], tmp[1]);
        }
        rtn.addClass('outspokes_targeted');
        
        var target_div = $('<div title="Jump to the target"></div>').addClass('outspokes_targeted_icon');
        rtn.find('.outspokes_commenter_name').before(target_div);
        
        target_div.click(function (e) {
          // console.log(tmp);
          $.scrollTo($(c.target), 200, { offset: -100});
          e.stopPropagation();
        });
      }
      
      return rtn;
    };
        
    this.render = function(c) {
      // remove the default no comments message because there's a comment to render
      this.no_comments.remove();
      
      c.num_replies = 0;
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
    
    this.filtering = {
      flattened: false
    };
    
    // Linearizes all comments and replies as children of #outspokes_comment_list
    this.flatten_comments = function() {
      var list = $("#outspokes_comment_list");
      if (this.filtering.flattened) {
        return list.children();
      }
      this.__flatten_recursive(list);
      this.filtering.flattened = true;
      return list.children();
    };
    
    this.__flatten_recursive = function(container) {
      var list = $("#outspokes_comment_list");
      var parent = this;
      $(container).children().each(function() {
        this.__container = container;
        $(this).addClass("outspokes_flattened");
        list.append($(this));
        parent.__flatten_recursive($("#" + parent.dom.reply_list(this.id)));
      });
    };
    
    // Returns comments to original threaded tree form and un-hides any hidden comments
    this.unflatten_comments = function() {
      if (! this.filtering.flattened) {
        return;
      }
      $("#outspokes_comment_list").children().each(function() { 
        $(this).show(400);
        $(this).removeClass("outspokes_flattened");
        $(this).appendTo(this.__container);
      });
      this.filtering.flattened = false;
      fb.i.comment.refresh_count();
    };
    
    // Sorts comment threads based on method
    this.sort_comments = function(method) {
      this.unflatten_comments();
      var posts = this.comments.children();
      posts.sort(method);
      posts.appendTo(this.comments);
    };
    
    // Flattens comments and hides them if method returns true for given comment
    this.filter_comments = function(fn) {
      var posts = this.flatten_comments();
      var count = 0;
      posts.each(function() {
        if (! fn(this)) {
          $(this).hide(400);
        } else {
          count++;
          $(this).show(400);
        }
      });
      fb.i.set_num_comments(count);
    };
    
    // Filters comments based on whether prop is true for each Comment object
    this.filter_by = function(prop) {
      this.filter_comments(function(post) {
        var post_id = fb.i.comment.dom.number_from_id(post.id);
        return fb.Feedback.all[post_id][prop];
      });
    };
    
    // Returns the timestamp of the most recent comment in given thread
    var age_of_thread = function(comment) {
      var dom = fb.i.comment.dom;
      var time = fb.Comment.all[dom.number_from_id(comment.id)].timestamp;
      fb.i.comment.visit_all_replies(comment, function(reply) {
        if (reply.timestamp > time) {
          time = reply.timestamp;
        }
      });
      return time;
    };
    
    this.sort_by_newest = function() {
      this.sort_comments(function(a, b) {
        var a_age = age_of_thread(a);
        var b_age = age_of_thread(b);
        return (b_age - a_age);
      });  
    };
    
    this.sort_by_oldest = function() {
      this.sort_comments(function(a, b) {
        var a_age = age_of_thread(a);
        var b_age = age_of_thread(b);
        return (a_age - b_age);
      });  
    };
    
    // Applies function fn to every Comment object that is a reply to the 
    // DOM comment c -- applies to actual Comment objects, not DOM elements
    this.visit_all_replies = function(c, fn) {
      c = $(c);
      var parent = this;
      c.find('#' + this.dom.reply_list(c.attr('id'))).children().each(function() {
        var this_id = parent.dom.number_from_id(this.id); // Extract id number of comment from id
        fn(fb.Comment.all[this_id]);
        parent.visit_all_replies(this, fn);
      });
    };
    
    this.collapse_all = function() {
        $(".outspokes_cmt_content").hide();
        $(".outspokes_cmt_date").hide();
        $(".outspokes_snippet").show();
        $(".outspokes_reply_count").show();
        $(".comment").addClass("outspokes_collapsed");
    };
    
    this.uncollapse_all = function() {
        $(".outspokes_cmt_content").show();
        $(".outspokes_cmt_date").show();
        $(".outspokes_snippet").hide();
        $(".outspokes_reply_count").hide();
        $(".comment").removeClass("outspokes_collapsed");
    };
    
    this.reset_target = function() {
      // Stop targetting if currently in process
      fb.i.dom.non_widget_elements.unbind(".elem_select");
      // Un-highlight element, first get its serialized path out of form
      var old_element = $(fb.i.comment.form.find("input[name='target']").attr("value"));
      // Remove any classes it may have had
      old_element.removeClass("outspokes_currently_hovering").removeClass("outspokes_selected_page_element");
      // Reset form target
      fb.i.comment.form.find("input[name='target']").attr("value","html");
      $('.outspokes_target_button').removeClass('outspokes_target_set');
      $('#outspokes_form_header').find('span').text('Comment');
    };
    
    // This is UI and should be moved to fb.Interface.comment
    this.refresh_count = function() {
      fb.i.set_num_comments(fb.getProperties(fb.Comment.all).length);
    };
    
  };
  
  function highlight_target(el_dom) {
    var el = $(el_dom);
    var over = function() {
      el.addClass("outspokes_currently_hovering")
    };
    var out = function() {
      el.removeClass("outspokes_currently_hovering")
    };
    return [over, out];
  }
