  var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
    fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.");
    if (!_fb.authorized()) {
      return false;
    }

    this.dom = {
      widget  : { 
        wrapper : 'outspokes',
        header  : 'topbar',
        headerLeft : 'topbarLeft',
        content : 'widget_content',
        help : 'help',
        help_content: 'help_content',
        toggle: 'toggle',
        contact: 'contactus',
        comment_count : 'comment-count',
      },
      admin   : {
        iframe  : 'outspokes_admin_panel_iframe',
        panel   : 'outspokes_admin_panel',
        open    : 'open_admin_panel',
        close   : 'close_admin_panel',
        overlay : 'outspokes_overlay',
      },
    }
    
    this.admin_panel = {
      dom   : this.dom,
      build : function(widget) {
        // the actual panel
        var admin_panel = $('<div></div>').attr('id',this.dom.admin.panel);
        var close_link = $("<a href='#'></a>").attr('id',this.dom.admin.close);
                
        close_link.click(function(e) {
          
          var content = fb.i.widget_content;
          var widget = fb.i.main_window;
          var help = fb.i.help_content;
          
          widget.animate( { height:"220px" }, { duration:250 } );
          help.addClass("hide"); //always make sure help is hidden before showing content
          content.show();
          
          fb.i.admin_panel.hide();
        });
        
        admin_panel.append(close_link);
        var iframe = $('<iframe>Your browser does not support iframes.</iframe>');
        iframe.attr({
          id : this.dom.admin.iframe,
          src : fb.env.admin_panel_address.pages,
          width : '100%',
          height : '100%', 
          frameborder : 0,
        });
        admin_panel.append(iframe);
        admin_panel.appendTo($('body'));
        
        // the background overlay
        $('<div></div>').attr('id',this.dom.admin.overlay).appendTo($('body'));

        // to open the panel from the widget
        var open_link = $('<a href="#">Admin Panel</a>').attr('id',this.dom.admin.open);

        open_link.click(function(e) {
          
          var content = fb.i.widget_content;
          var widget = fb.i.main_window;
          
          widget.animate( { height:"20px" }, { duration:250 } );
          content.hide();
          
          fb.i.admin_panel.show();
          e.stopPropagation();
        });
        
        widget.append(open_link);
      },
      show : function() {
        $('#' + fb.i.dom.admin.panel).show();
        $('#' + fb.i.dom.admin.overlay).show();
      },
      hide : function() {
        $('#' + fb.i.dom.admin.panel).hide();
        $('#' + fb.i.dom.admin.overlay).hide();
      },
      set_to_commenters: function() {
        $("#" + this.dom.admin.iframe)[0].src = fb.env.admin_panel_address.commenters;
      }
    }
    
    this.main_window = $('<div></div>').attr('id',this.dom.widget.wrapper);
    
    if (fb.env.first_visit) {
      this.main_window.css({'height':'20px'});
      
      $('#' + this.dom.widget.content).hide();
            
      var intro_bubble = $('<div></div>').attr('id','bubble');
      var intro_bubble_content = "<p id='bubble_content'>Welcome to the Outspokes feedback widget!" + 
      "<br />To start giving feedback, click somewhere on the bar, and you'll be able to see comments" + 
      " that other people have left and leave your own!<br />Happy commenting!</p>";
      var close_intro_bubble = $('<a href="#" id="close_intro">X</a>');
      
      close_intro_bubble.click(function() 
        {
          $("#bubble").hide();
        }
      );
      
      
      intro_bubble.append(close_intro_bubble);
      
      intro_bubble.append(intro_bubble_content);
      
      this.main_window.append(intro_bubble);
      
    } else {
      $("#bubble").hide();
      this.main_window.css({'height':'227px'});
    }

    this.topbar = $('<div></div>').attr('id',this.dom.widget.header);
    var topbarLeft = $('<div></div>').attr('id',this.dom.widget.headerLeft);
    var logo = $('<a href="http://www.outspokes.com" target="_blank">&nbsp;</a>');
    logo.css({
      'display' : 'block',
      'float'   : 'left',
      'height'  : '20px',
      'width'   : '100px',
      'backgroundImage' : 'url(' + fb.env.logo_address + ')',
      'backgroundRepeat' : 'no-repeat',
    });
    topbarLeft.append(logo);

    var comment_count = $('<span>'+ fb.getProperties(fb.Feedback.all).length + ' Comments</span>');
    comment_count.attr('id', this.dom.widget.comment_count);
    this.set_num_comments = function(num_comments) {
      comment_count.text(num_comments + ' Comments');
    }
    topbarLeft.append(comment_count);
    this.topbar.append(topbarLeft);

    var help_link = $('<a href="#">(?)</a>').attr('id',this.dom.widget.help);
    help_link.click(function(e) {
      var content = fb.i.widget_content;
      var help = fb.i.help_content;
      var widget = fb.i.main_window;

      if (widget.height() == '20') {
        widget.animate( { height:"220px" }, { duration:250 } );
        content.hide();
        help.removeClass("hide");
      } else {
        content.toggle(); //this toggle is not working
        help.toggleClass("hide");
      }
      
      $("#bubble").hide();
      
      e.stopPropagation();
    });
    this.topbar.append(help_link);
   
    var contact_link = $('<a href="mailto:outspokes@outspokes.com">Contact</a>').attr('id',this.dom.widget.contact)
    this.topbar.append(contact_link);
 
    this.topbar.click(function() {
      var content = fb.i.widget_content;
      var help = fb.i.help_content;
      var widget = fb.i.main_window;
      
      if (widget.height() == '20') {
        widget.animate( { height:"220px" }, { duration:250 } );
        help.addClass("hide"); //always make sure help is hidden before showing content
        content.show();
      } else {
        widget.animate( { height:"20px" }, { duration:250 } );
        content.hide();
      }
      
      $("#bubble").hide();
      
    });

    this.main_window.append(this.topbar);
    this.main_window.append($('<div style="clear:both;"></div>'));

    this.widget_content = $('<div></div>').attr('id',this.dom.widget.content);
    this.help_content = $('<div><h1>Outspokes Help</h1></div>').attr('id', this.dom.widget.help_content);
    
    var help_copy = "<h2>Minimized</h2>" +

    "<p>Click on the center of the bar to expand Outspokes' feedback widget and start giving the owner of the page feedback!  " + 
    "Also, you can click on our logo to go to outspokes.com and learn more about our service." +

    "<h2>General</h2>" +

    "<p>Click on a comment to minimize or maximize it.  If a comment is targeted, hover your mouse over it" + 
    "to see what element of the page has been attached to the comment.</p>" +

    "<p>To leave a comment, type in the text box on the right side of the widget, then click on the post button to the" + 
    "bottom right of the text box to submit it.</p>" +
    "<p>If you'd like to attach this comment to a portion of the page you're viewing, click the target icon on the top right of" + 
    "the text box.</p>" +

    "<p>To search the comments left on this page by keyword, type some text in the search bar on the top right of the widget panel," +
    "and type enter." +
    "To filter your result, use the drop-down bar above the list of comments to select how you'd want to filter the comments.</p>" +

    "<p>Agreeing/disagreeing with a comment gives the person who requested feedback " +
    "information about whether other commenters generally agree or disagree with a comment that another commenter has left.  " +
    "Please note, once you have agreed or disagreed with a comment, you cannot change your vote.</p>";
    
    this.help_content.append(help_copy);
    
    this.help_content.addClass("hide");

    this.main_window.append(this.widget_content);
    this.main_window.append(this.help_content);
    if (_fb.admin()) {
      this.admin_panel.build(this.topbar);
    }
    
    this.main_window.appendTo($('body'));

    this.comment = new fb.Interface.comment(this);

    fb.Interface.instantiated = true;  
  };

  fb.Interface.prototype.div = function() {
    return $('<div></div>');
  };

  fb.Interface.instantiated = false;
