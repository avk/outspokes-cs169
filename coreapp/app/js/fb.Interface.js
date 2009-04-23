  var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
    fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.");
    if (!fb.env.authorized()) {
      return false;
    }

    $('head').append('<link rel="stylesheet" type="text/css" href="' + fb.env.css_address + '" />');

    this.dom = {
      widget  : { 
        wrapper : 'outspokes',
        header  : 'topbar',
    		content : 'widget_content',
    		comments_header : 'comments_topbar',
    		help : 'help',
    		help_content: 'help_content',
    		toggle: 'toggle',
      },
      admin   : {
        panel   : 'outspokes_admin_panel',
        open    : 'open_admin_panel',
        close   : 'close_admin_panel',
        overlay : 'outspokes_overlay',
      },
    }
    
    this.admin_panel = {
      dom   : this.dom,
      build : function(widget) { // TODO: only show for admins
        // the actual panel
        var admin_panel = $('<div></div>').attr('id',this.dom.admin.panel);
        var close_link = $("<a href='#'>x</a>").attr('id',this.dom.admin.close);
        close_link.click(this.hide);
        admin_panel.append(close_link);
        admin_panel.append("<h1>I'm the ADMIN, bitches!</h1>"); // TODO: replace with coreapp iframe
        admin_panel.appendTo($('body'));
        
        // the background overlay
        $('<div></div>').attr('id',this.dom.admin.overlay).appendTo($('body'));

        // to open the panel from the widget
        var open_link = $('<a href="#">admin</a>').attr('id',this.dom.admin.open);
        open_link.click(this.show);
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
    }
    
    this.main_window = $('<div></div>').attr('id',this.dom.widget.wrapper);

  	this.topbar = $('<div></div>').attr('id',this.dom.widget.header);
   	var help_link = $('<a href="#">(?)</a>').attr('id',this.dom.widget.help);
  	this.topbar.append('<h1><a href="http://www.outspokes.com" target="_blank">outspokes <em>alpha</em></a></h1>');
	
  	help_link.click(function() {
  		var content = fb.i.widget_content;
  		var help = fb.i.help_content;
  		var widget = fb.i.main_window;
  		if (widget.height() == '20') {
  			widget.animate( { height:"220px" }, { duration:500 } );
  			help.removeClass("hide");
  		} else {
  			content.toggle();
  			help.toggleClass("hide");
  		}
  	});
	
  	this.main_window.append(help_link);

  	this.topbar.click(function() {
  		var content = fb.i.widget_content;
  		var help = fb.i.help_content;
  		var widget = fb.i.main_window;
  		if (widget.height() == '20') {
  			widget.animate( { height:"220px" }, { duration:500 } );
  			help.addClass("hide"); //always make sure help is hidden before showing content
  			content.show();
  		} else {
  			widget.animate( { height:"20px" }, { duration:500 } );
  			content.hide();
  		}
  	});
	
  	this.main_window.append(this.topbar);

  	this.widget_content = $('<div></div>').attr('id',this.dom.widget.content);
  	this.help_content = $('<div>help yourself</div>').attr('id', this.dom.widget.help_content);
  	this.help_content.addClass("hide");
	
  	this.chead = $('<div></div>').attr('id',this.dom.widget.comments_header);
  	var comment_span = $('<span>'+ fb.getProperties(fb.Feedback.all).length + ' comments</span>');
  	this.chead.append(comment_span);
  	this.chead.append('<select id="comments_filter"><option>newest</option><option>oldest</option><option>mine</option><option>targeted</option><option>consensus</option></select>');
  	this.chead.append('<a id="refresh" href="javascript:location.reload()">refresh</a>'); /*fix*/
	
  	this.set_num_comments = function(num_comments) {
  	  comment_span.text(num_comments + ' comments');
  	};
	
  	this.widget_content.append(this.chead);
  	this.main_window.append(this.widget_content);
	
  	this.main_window.append(this.help_content);
	
    this.admin_panel.build(this.topbar);

    this.main_window.appendTo($('body'));
  
    this.comment = new fb.Interface.comment(this);
  
    fb.Interface.instantiated = true;
  
  };
  
  fb.Interface.prototype.div = function() {
  	return $('<div></div>');
  };

  fb.Interface.instantiated = false;
