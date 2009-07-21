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
        designs : 'widget_designs',
        help : 'help',
        logout: 'logout',
        help_content: 'help_content',
        contact: 'contactus',
        topbar_height : '28px',
        topbar_int_height : 28, //same as topbar_height in int form
        numerical_height : 250,
        height : '250px',
        navigation : 'navigation',
        collapse : 'outspokes_collapse_all',
        uncollapse : 'outspokes_uncollapse_all'
      },
      admin   : {
        iframe  : 'outspokes_admin_panel_iframe',
        panel   : 'outspokes_admin_panel',
        open    : 'open_admin_panel',
        close   : 'close_admin_panel',
        overlay : 'outspokes_overlay',
      },
      non_widget_elements : $("body *:not(#outspokes *, #outspokes, #outspokes_admin_panel," +
        " #outspokes_admin_panel *, #outspokes_overlay, #outspokes_overlay *)"),
    };
    
    this.main_window = $('<div></div>').attr('id',this.dom.widget.wrapper);
    
    
    // WIDGET DISPLAYING //////////////////////////////////////////////////////////////////
    
    this.is_widget_minimized = function() {
      return (this.main_window.height() === this.dom.widget.topbar_int_height) ? true : false;
    };
    
    this.is_widget_maximized = function() {
      return !this.is_widget_minimized();
    };
    
    this.toggle_widget = function() {
      if (this.is_widget_minimized()) {
        this.show_widget();
      } else {
        this.hide_widget();
      }
    };
    
    this.show_widget = function() {
      var length;
      if (arguments.length == 0) {
        length = this.dom.widget.numerical_height;
      } else if (! arguments[0]) {
        length = 0;
      }
      fb.save_state("widget_position", 'up');
      this.main_window.animate( 
        { height : this.dom.widget.height }, 
        { duration : length } 
      );
      // should only display the sort menu for the current navigation link
      for (var which_element = 0; which_element < this.nav.elements.list.length; which_element++) {
        this.nav.elements.list[which_element].filter('.outspokes-current').find('.hide_when_tab_unselected').show();
      }
    };
    
    this.hide_widget = function() {
      var length;
      if (arguments.length == 0) {
        length = this.dom.widget.numerical_height;
      } else if (! arguments[0]) {
        length = 0;
      }
      fb.save_state("widget_position", 'down');
      this.main_window.animate( 
        { height : this.dom.widget.topbar_height }, 
        { duration : length } 
      );
      // hide the sort menu for all navigation links, 
      // since it doesn't have any visible effect when the widget's collapsed
      for (var which_element = 0; which_element < this.nav.elements.list.length; which_element++) {
        this.nav.elements.list[which_element].find('.hide_when_tab_unselected').hide();
      }
    };
    
    
    
    // TOPBAR //////////////////////////////////////////////////////////////////
    
    this.topbar = $('<div></div>').attr('id',this.dom.widget.header);
    this.topbar.click(function() { fb.i.toggle_widget(); });
    
    var topbarLeft = $('<div></div>').attr('id',this.dom.widget.headerLeft);
    this.topbar.append(topbarLeft);
    
    // Logo
    var logo = $('<a href="' + fb.env.base_domain + '" target="_blank"></a>');
    logo.append('<img src="' + fb.env.logo_address + '" alt="outspokes" />');
    logo.attr('id', 'outspokes_logo');    
    // clicking on the logo shouldn't toggle the widget:
    logo.click( function(e) { e.stopPropagation(); } );
    topbarLeft.append(logo);
    
    
    
    // NAVIGATION //////////////////////////////////////////////////////////////////
    
    this.nav = {
      /*
        TO ADD A NEW NAVIGATION ELEMENT: 
        add an entry to elements.labels, elements.counts, and elements.content
      */
      
      // because this.dom is inaccessible below
      dom : this.dom,
      // DOM element representing navigation bar (initialized by build)
      bar : null, 
      // where the user has navigated to
      current : null,
      // equivalent to navigating to a specific element:
      setCurrent : function(which_element) {
        if (this.current) {
          this.current.removeClass('outspokes-current');
        }
        this.current = this.elements.list[which_element];
        this.current.addClass('outspokes-current');
      },
      
      // ordered set of navigation elements:
      elements : {
        // ordered set of DOM elements
        list : [],
        // the ***singular*** text content of the label
        // same order as list of elements
        labels : [
          'Comment',
          'Design'
        ],
        // the number of feebdacks under this navigation element
        // same order as list of elements
        counts : [
          fb.getProperties(fb.Comment.all).length,
          0 // fb.getProperties(fb.UserStyle.all).length
        ],
        // which content the navigation elements correspond to,
        // these reference variable names in this class (fb.Interface)
        // same order as list of elements
        content : [
          "widget_content",
          "designs"
        ],
        // triggered when a navigation element is clicked,
        // same order as list of elements
        callbacks : [
          function() {
            fb.Comment.get();
            return true;
          },
          function() {
            fb.UserStyle.get();
            return true;
          }
        ],
        /*
        clicking on an element:
          makes it the current element
          shows it's content
          shows it's sort menu
          hides the content of all the other elements
          hides the sort menus of all the other elements
        */
        click : function(clicked_element, event) {
          for (var which_element = 0; which_element < fb.i.nav.elements.content.length; which_element++) {
            var content = fb.i[ fb.i.nav.elements.content[which_element] ];
            if (clicked_element === fb.i.nav.elements.list[which_element][0]) {
              var callback = fb.i.nav.elements.callbacks[which_element];
              if (callback && fb.i.nav.current[0] !== clicked_element) {
                if (!callback()) {
                  return;
                }
              }
              
              fb.i.nav.setCurrent(which_element);
              fb.i.nav.elements.list[which_element].find('.hide_when_tab_unselected').show();
              // Save the current tab in widget cookie state
              fb.save_state("widget_tab", which_element);
              content.show();              
            } else {
              content.hide();
              fb.i.nav.elements.list[which_element].find('.hide_when_tab_unselected').hide();
            }
          }
        }
      },
      
      // creates the bar and returns it
      build : function() {
        this.bar = $('<ul></ul>');
        this.bar.addClass(this.dom.widget.navigation);
        this.bar.click( function(e) { 
          // if the widget is open, don't collapse it
          if (fb.i.main_window.height() > fb.i.dom.widget.topbar_int_height) {
            e.stopPropagation();
          }
        });
        
        // builds each element, labels it, and attaches a uniform onclick handler
        for (var which_element = 0; which_element < this.elements.labels.length; which_element++) {
          var element = $('<li></li>');
          element.append('<span></span>'); // for the text label
          
          // set_label_count depends on element being in this.elements.list:
          this.elements.list.push(element);
          this.set_label_count( this.elements.counts[which_element], which_element );
          
          element.click( function(e) { fb.i.nav.elements.click(this, e) });
          this.bar.append(element);
        }
        // set first navigation element to current
        this.setCurrent(0);
        
        return this.bar;
      },
      // sets a navigation element label
      // which_element is an index into this.elements
      set_label_count : function(count, which_element) {
        var new_label = count + ' ' + this.elements.labels[which_element];
        if (count !== 1) {
          new_label += 's';
        }
        this.elements.list[which_element].find('span').text(new_label);
      }
    }
    topbarLeft.append(this.nav.build());
    
    this.set_num_comments = function(num_comments) {
      fb.i.nav.set_label_count(num_comments, 0); // Comments is the first navigation tab
    };
    
    
    // COMMENT SORT MENU //////////////////////////////////////////////////////////////////
    
    var sort_dropdown = $('<select id="comments_filter" class="hide_when_tab_unselected"><option>Newest first</option><option>Oldest first</option>' + 
        '<option>Popular</option><option>Unpopular</option><option>Controversial</option>' +
        '<option>Neutral</option>');
    
    this.sorting = {
      sorting_mode : 0,
      modes : [ "new", "old", "popular", "unpopular", "controversial", "neutral" ]
    };
        
    sort_dropdown.click(function(e) {
      e.stopPropagation(); // Don't trigger outspokes minimize when clicking on dropdown
    });
    var sorting = this.sorting;
    
    $.each(sorting.modes, function(mode_no, mode) {
      sort_dropdown.children().eq(mode_no).click(function(e) {
        sorting.sorting_mode = mode_no;
        if (mode_no == 0) {
          fb.i.comment.sort_by_newest();
        } else if (mode_no == 1) {
          fb.i.comment.sort_by_oldest();
        } else {
          fb.i.comment.filter_by(mode + "?");
        }
      });
    });
    
    this.nav.elements.list[0].append(sort_dropdown);
    
    // COMMENT TOGGLE LINKS
    
    this.collapse_link = $('<a class="hide_when_tab_unselected" title="Collapse all comments">&nbsp;</a>').attr('id',this.dom.widget.collapse);
    this.nav.elements.list[0].append(this.collapse_link);
    this.collapse_link.click(function(e) {
        fb.i.comment.collapse_all();
        
        // don't toggle the widget if it's maximized because you want to read help content
        if (fb.i.is_widget_maximized()) {
          e.stopPropagation();
        }
    })

    this.uncollapse_link = $('<a class="hide_when_tab_unselected" title="Uncollapse all comments">&nbsp;</a>').attr('id',this.dom.widget.uncollapse);
    this.nav.elements.list[0].append(this.uncollapse_link);
    this.uncollapse_link.click(function(e) {
        fb.i.comment.uncollapse_all();
        
        // don't toggle the widget if it's maximized because you want to read help content
        if (fb.i.is_widget_maximized()) {
          e.stopPropagation();
        }
    })

    // HELP LINK //////////////////////////////////////////////////////////////////

    this.help_link = $('<a></a>').attr('id',this.dom.widget.help);
    this.help_link.append('<img src="' +  fb.env.help_address  + '" alt="Outspokes Help" title="Outspokes Help"/>');
    
    // the help link will behave like the other navigation links (part 1):
    this.nav.elements.list.push(this.help_link);
    this.nav.elements.content.push('help_content'); // refers to this.help_content
    
    this.help_link.click(function(e) {
      // the help link will behave like the other navigation links (part 2):
      fb.i.nav.elements.click(this, e);
      
      // don't toggle the widget if it's maximized because you want to read help content
      if (fb.i.is_widget_maximized()) {
        e.stopPropagation();
      }
    });
    this.topbar.append(this.help_link);

    // WIDGET LOGOUT LINK /////////////////////////////////////////////////////////
    this.logout_link = $('<a>Logout</a>').attr('id',this.dom.widget.logout);
    this.logout_link.click(function() {
      // do logout stuff here
      if (_fb.admin()) {
        var answer = confirm("Are you sure you want to log out? To log back in, bookmark this page or visit your Outspokes.com dashboard.");
      } else {
        var answer = confirm("Are you sure you want to log out? To give more feedback, bookmark this page or click the link in your invite email.");
      }
      if (answer){
        fb.i.user_style.unapply_current_design();
        fb.i.target.startOver();
        fb.cookie('outspokes_widget_state', null);  
        fb.cookie('fb_hash_url_token', null);
        fb.cookie('fb_hash_admin_validation_token', null);
        fb.$("#outspokes_admin_panel").remove();
        fb.$("#outspokes_overlay").remove();
        fb.$("#outspokes").remove();
      }
      return false;
    });
    this.topbar.append(this.logout_link);

    // ADMIN PANEL //////////////////////////////////////////////////////////////////
    
    this.admin_panel = {
      dom   : this.dom,
      build : function() {
        // the actual panel
        var admin_panel = $('<div></div>').attr('id',this.dom.admin.panel);
        
        var close_link = $("<a></a>").attr('id',this.dom.admin.close);
        var widget_location; // State accessed via closure by close_link.click and open_link.click
        close_link.click(function(e) {
          fb.i.admin_panel.hide();
          if (widget_location != "down") {
            fb.i.show_widget();
          }
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
        var open_link = $('<a>Admin Panel</a>').attr('id',this.dom.admin.open);
        open_link.click(function(e) {
          // don't toggle the widget if I'm opening the admin panel, just hide it
          e.stopPropagation();
          widget_location = fb.get_state("widget_position");
          fb.i.hide_widget();
          
          fb.i.admin_panel.show();
        });
        
        return open_link;
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
    
    if (_fb.admin()) {
      this.topbar.append(this.admin_panel.build());
    }
  
    // FIRST VISIT //////////////////////////////////////////////////////////////////
    
    if (fb.env.first_visit) {
      this.hide_widget();
      
      if (!_fb.admin()) { // only commenters see the intro on their first visit        
        var intro_bubble = $('<div></div>').attr('id','bubble');
        
        var close_bubble = function() { $("#bubble").hide(); }
        var close_bubble_link = $('<a>X</a>').attr('id','close_intro');
        close_bubble_link.click( close_bubble );
        intro_bubble.append(close_bubble_link);
        
        intro_bubble.append("<p id='bubble_content'>Welcome to <strong>Outspokes</strong>.<br />" + 
          "<span>Give feedback by clicking on the bar. Bookmark this page to easily give feedback later.</span></p>");
        
        // the bubble should be closed when clicking on the following:
        this.topbar.click( close_bubble );
        this.help_link.click( close_bubble );
        
        this.topbar.append(intro_bubble);
      }
    }
    
    
    // HELP VIEW //////////////////////////////////////////////////////////////////
    
    this.help_content = $('<div></div>').attr('id', this.dom.widget.help_content);
    
    var main_help = $('<div class="outspokes_left_panel"><h1>Help</h1></div>');
    var secondary_help = $('<div class="outspokes_right_panel"></div>');
    
    var who = (_fb.admin()) ? 'admin' : 'commenter';
    
    main_help.append("" +
    "<div class='outspokes_question'>" + 
    "<h2>What's this bar at the bottom of the page?</h2>" +
      "<p>The person running this site wants to know what you think. " + 
      "The <a href='" + fb.env.base_domain + "'>Outspokes</a> widget " + 
      "(where you're reading this now) is here to help!</p>" + 
      
      "<p>The Outspokes widget lives at the bottom of every page of this site. " + 
      "It contains feedback people like you have left on the particular page you're on. " + 
      "You can collapse (or expand) the widget by clicking on the silver bar above.</p>" + 
      
      "<p><a class='outspokes_widget_cta' href='" + 
      fb.env.base_domain + "?intro=" + who + "'>" + 
      "Watch a 30 second introduction!</a></p>" + 
    "</div>");
    
    main_help.append("" +
    "<div class='outspokes_question'>" + 
    "<h2>How do I get rid of the bar?</h2>" +
      "<p>You can close the Outspokes widget by clicking the 'Logout' link right next to the help link ('?') that got you here.</p>" + 
    "</div>");
    
    secondary_help.append("" +
    "<p><a href='" + fb.env.base_domain + "' style='font-size:2em'>Learn more</a><br />" + 
    "Problems: " + 
    "<a href='mailto:support@outspokes.com'>support@outspokes.com</a><br />" +
    "Feedback: " + 
    "<a href='mailto:feedback@outspokes.com'>feedback@outspokes.com</a><br />");
    
    this.help_content.append(main_help);
    this.help_content.append(secondary_help);
    this.help_content.addClass("hide");

    // JUGGERNAUT
    // was this.juggernaut='<iframe src ="'+fb.env.juggernaut_iframe_address+_fb.page_id()+'" style="border:0;" height="0" width="0"></iframe>';
    var juggernaut = $('<iframe><iframe').attr('src', fb.env.juggernaut_iframe_address+_fb.page_id());
    juggernaut.css("border", 0)
    juggernaut.attr('height', 0);
    juggernaut.attr('width',  0);
    juggernaut.appendTo($('body'))

    // WRAPUP //////////////////////////////////////////////////////////////////

    this.widget_content = $('<div></div>').attr('id',this.dom.widget.content);
    this.designs = $('<div></div>').attr('id',this.dom.widget.designs).hide();

    this.main_window.append(this.topbar);
    this.main_window.append($('<div style="clear:both;"></div>'));
    this.main_window.append(this.widget_content);
    this.main_window.append(this.designs);
    this.main_window.append(this.help_content);
    this.main_window.appendTo($('body'));

    // make vertical space to still be able to scroll to the bottom of the page when the widget is expanded
    $('html').height( $(document).height() + this.dom.widget.numerical_height );

    this.comment = new fb.Interface.comment(this);
    this.user_style = new fb.Interface.user_style(this);
    this.target = new fb.Interface.target(this);
    
    fb.Interface.feedback_last_updated_at=new Date;
    fb.Interface.feedback_last_updated_at.setDate(0);
    setInterval(function() {
        if(window.location.hash === "#refreshcomments" && ((new Date).getTime() - fb.Interface.feedback_last_updated_at.getTime()) > 3000) {
            fb.Interface.feedback_last_updated_at=new Date;
            fb.Comment.get();
            var go_back_tries=0;
            while(window.location.hash === "#refreshcomments" && go_back_tries++ < 10) {
                history.go(-1);
            }
            if(window.location.hash === "#refreshcomments") {
                window.location.hash="#";
            }
        }
    }, 2000)
    
    fb.Interface.instantiated = true;  
  };

  fb.Interface.prototype.div = function() {
    return $('<div></div>');
  };

  fb.Interface.instantiated = false;
