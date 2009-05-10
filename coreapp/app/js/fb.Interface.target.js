  var $ = fb.$;

  fb.Interface.target = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      
    };
    var dom = this.dom;
    
    // maps DOM objects (created by build) to instances of Target
    this.all = {};
    // the currently selected Target (to be styled)
    this.current = {
      target : null,
      html : null
    }; // if changed, also change in clearAll()
    
    this.target_header = $('<div><h1>Targeting</h1></div>').attr('id', 'outspokes_target_header');
    var target_button = $('<img class="outspokes_target_button" src="' + fb.env.target_address + '" />');
    target_button.click(function() {
      fb.Target.pick(function(target) { // callback
        
      });
    });
    this.target_header.append(target_button);
    
    
    this.target_list = $('<ul></ul>').attr('id','outspokes_target_list');
    
    
    this.target_footer = $('<div></div>').attr('id','outspokes_target_footer');
    var clear_targets = $('<a href="#">Clear</a>');
    clear_targets.click(function(e) {
      fb.i.target.startOver();
      return false;
    });
    var save_targets = $('<a href="#" onclick="return false;">Save</a>').css('padding-left','20px');
    
    this.target_footer.append(clear_targets);
    this.target_footer.append(save_targets);
    
    
    this.build = function(target) {
      var html = $('<li></li>').text(target.selector);
      html.attr('title', target.selector);
      html.click( function(e) {
        fb.i.target.setCurrent(this);
      });
      
      this.all[html.attr('title')] = target;
      this.target_list.append(html);
      this.setCurrent(html);
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
        // $(which_target).remove();         // delete the interface element
        this.all[which_target].delete();  // delete the instance of Target
        delete this.all[which_target];    // delete the reference in list
      }
      this.target_list.empty(); // doesn't quite work...
      this.all = {};
      this.current = {
        target : null,
        html : null
      }
      this.build( new fb.Target("html > body") );
    }
    
    this.startOver();
    self.user_style.your_targets.append(this.target_header);
    self.user_style.your_targets.append(this.target_list);
    self.user_style.your_targets.append(this.target_footer);
    
  };