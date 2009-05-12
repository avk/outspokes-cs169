  var $ = fb.$;

  fb.Interface.target = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      
    };
    var dom = this.dom;
    
    // maps target titles (created by build) to instances of Target
    this.all = {};
    // the currently selected Target (to be styled)
    this.current = {
      target : null,
      html : null
    }; // if changed, also change in clearAll()
    
    this.target_header = $('<div></div>').attr('id', 'outspokes_target_header');
    var target_button = $('<img class="outspokes_target_button" src="' + fb.env.target_address + '" />');


    target_button.click(function() {
      fb.Target.pick(function(target) { // callback
        
      });
    });
    this.target_header.append(target_button);
    this.target_header.append($('<span>Targeting</span>'));
   // this.target_header.append($('<div style="clear:both;"></div>'));
    
    
    this.target_list = $('<ul></ul>').attr('id','outspokes_target_list');
    
    
    this.target_footer = $('<div></div>').attr('id','outspokes_target_footer');
    var clear_targets = $('<a href="#">Clear</a>');
    clear_targets.click(function(e) {
      fb.i.target.startOver();
      return false;
    });
    var save_targets = $('<a href="#">Save</a>').css('padding-left','20px');
    save_targets.click(function(e) {
      fb.UserStyle.post(fb.i.target.all);
      return false;
    });
    
    this.target_footer.append(clear_targets);
    this.target_footer.append(save_targets);
    
    
    this.build = function(target) {
      var html = $('<li></li>');
      html.attr('title', target.selector);
      html.click( function(e) {
        fb.i.target.setCurrent(this);
      });
      
      if (this.target_list.find('li').length > 0) {
        var delete_target = $('<a href="#">x</a>');
        delete_target.click(function(e) {
          fb.i.target.remove( $(this).parent('li').attr('title') );
        });
        html.append(delete_target);
      }
      
      var inner = $('<p></p>');
      inner.append(target.selector);
      html.append(inner);
      
      this.all[html.attr('title')] = target;
      this.target_list.append(html);
      this.setCurrent(html);
      return html;
    }
    
    this.setCurrent = function(target_html) {
      if (this.current.html) { // unset current target's styles
        this.current.html.removeClass('outspokes_current_target');
      }
      
      target_html = $(target_html);
      this.current.html = target_html;
      this.current.target = this.all[target_html.attr('title')];
      this.current.html.addClass('outspokes_current_target');
    }
    
    this.startOver = function() {
      for (var which_target in this.all) {
        this.remove(which_target);
      }
      this.target_list.empty();
      this.all = {};
      this.current = {
        target : null,
        html : null
      }
      var default_target = new fb.Target("html > body");
      if (!fb.i) {
        this.build(default_target);
      }
    }
    
    this.remove = function(target_selector) {
      var target = this.all[target_selector];
      if (target.build) {
        target.build.remove(); // delete from the DOM
      }
      target.delete();  // delete the instance of Target
      delete target;    // delete the reference in list
    };
    
    this.startOver();
    
    self.user_style.your_targets.append(this.target_header);
    self.user_style.your_targets.append($('<div id="outspokes_target_list_wrap"></div>').append(this.target_list));
    self.user_style.your_targets.append(this.target_footer);
    
  };
