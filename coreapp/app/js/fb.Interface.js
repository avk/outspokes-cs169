  var $ = fb.$;
  /**
   * fb.Interface class to create an instance of the ui.
   * Note: Only one instance may be made.
   * @classDescription Creates an instance of the ui
   * @constructor
   */
  fb.Interface = function() {
    fb.assert_false(fb.Interface.instantiated, "Can not create more than one instance of the interface.");
    if (!fb.env.authorized) {
      return false;
    }

    $('head').append('<link rel="stylesheet" type="text/css" href="' + fb.env.css_address + '" />');

    this.dom = {
      widget  : { 
        wrapper : 'outspokes',
        header  : 'topbar',
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
    this.main_window.append($('<h1>outspokes y&#8216;all</h1>').attr('id',this.dom.widget.header));
    this.admin_panel.build(this.main_window);
    this.main_window.appendTo($('body'));
    
    this.comment = new fb.Interface.comment(this);
    
    fb.Interface.instantiated = true;
  };
  
  fb.Interface.prototype.div = function() {
  	return $('<div></div>');
  };

  fb.Interface.instantiated = false;
