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
    this.default_target = null;
    
    // returns true if there have been any edits and false otherwise
    this.changes_to_targets = function(cares_about_new_targets) {
      if (typeof cares_about_new_targets === "undefined") {
        cares_about_new_targets = false;
      }
      var changes = false;
      if (fb.getProperties(fb.i.target.all).length > 1 && cares_about_new_targets) { // there's more than one target
        changes = true;
      } else {
        $.each(fb.i.target.all, function(selector, target) {
          if (fb.getProperties(target.new_styles).length > 0) { // target has edits
            changes = true;
            return false;
          }
        });
      }
      return changes;
    };
    
    this.target_header = $('<div></div>').attr('id', 'outspokes_target_header');
    var target_button = $('<img class="outspokes_target_button" src="' + fb.env.target_address + '" />');

    target_button.click(function() {
      fb.Target.pick(function(target) { // callback

      });
    });
    this.target_header.append(target_button);
    this.target_header.append($('<span>Targeting</span>'));
    
    this.target_list = $('<ul></ul>').attr('id','outspokes_target_list');
    
    
    this.target_footer = $('<div></div>').attr('id','outspokes_target_footer');
    //var clear_targets = $('<a>Clear</a>').attr('id', 'outspokes_clear_styles');
    var clear_targets = $('<input class="button" type="submit" value="Clear" />').attr('id', 'outspokes_clear_styles');
    clear_targets.click(function(e) {
      var answer = confirm("This will delete all of your changes.  Are you sure?");
      if (answer) {
        fb.i.target.startOver();
      }
      return false;
    });
    //var save_targets = $('<a>Save</a>').attr('id', 'outspokes_save_edit');
    var save_targets = $('<input class="button" type="submit" value="Save" />').attr('id', 'outspokes_save_edit');
    save_targets.click(function(e) {
      if (fb.i.target.changes_to_targets()) {
        fb.UserStyle.post(fb.i.target.all);
        fb.i.target.startOver();
        fb.i.user_style.slide(fb.i.user_style.new_edit_view, fb.i.user_style.edits_view);
        fb.i.user_style.new_edit_is_current = false;
      } else {
        alert("You must make some changes before saving.");
      }
      return false;
    });
    
    this.target_footer.append(clear_targets);
    this.target_footer.append(save_targets);
    
    
    this.build = function(target) {
      var html = $('<li></li>');

      var hover_functions = fb.highlight_target(target.element);
      html.hover(hover_functions[0], hover_functions[1]);
      target.__unHover = hover_functions[1];
      
      var target_readable = target.selector;
      target_readable = target_readable.replace(/eq\(/g, "");
      target_readable = target_readable.replace(/\)/g, "");
      target_readable = target_readable.replace(/html > /g, "");
      target_readable = target_readable.replace(/body:0/g, "body");
      
      html.attr('title', target.selector);
      html.click( function(e) {
        fb.i.target.setCurrent(target);
      });
      
      if (this.target_list.find('li').length > 0) {
        var delete_target = $('<a>x</a>').attr('id', 'outspokes_delete_style_edit');
        delete_target.click(function(e) {
          fb.i.target.remove( $(this).parent('li').attr('title') );
        });
        html.append(delete_target);
      }
      
      // onclick handler for target names
      function rename(e, self) {
        var selector = target.name || target_readable;
        var new_name = $('<input type="text" value="' + selector + '"/>');
        var old_name = $(self).replaceWith(new_name); // important: removes any event handlers
        new_name[0].select();
        
        // Set this target's name when you press enter
        new_name.keydown(function(e) {
          if (e.keyCode === 13) { // enter
            $(this).blur();
          }
        });
        
        // Removes the text input and reinserts the paragraph with the new value
        new_name.blur(function(e) {
          if (this.value === "") { 
            // revert to the default
            this.value = target_readable;
          }
          old_name.text(this.value);
          target.name = this.value; // save it, so that you can keep renaming
          var replaced = $(this).replaceWith(old_name);
          // reattach the click handler because it got removed during replaceWith
          old_name.click( function(e) { rename(e, this) });
        });
      }
      
      var inner = $('<p></p>');
      inner.append(target_readable);
      inner.click( function(e) { rename(e, this) });
      html.append(inner);
      
      this.all[html.attr('title')] = target;
      this.target_list.append(html);
      target.build = html;
      this.setCurrent(target);
    };
    
    this.setCurrent = function(target) {
      if (this.current.html) { // unset current target's styles
        this.current.html.removeClass('outspokes_current_target');
        this.current.target.element.removeClass('outspokes_selected_page_element');
      }
      
      this.current.html = target.build;
      this.current.target = this.all[target.build.attr('title')];
      if (this.current.target.element[0] !== document.body) {
        this.current.target.element.addClass("outspokes_selected_page_element");
      }
      this.current.html.addClass('outspokes_current_target');
      self.user_style.populate_fields(target);
    };
    
    this.startOver = function() {
      for (var which_target in this.all) {
        this.remove(which_target, true);
      }
      this.target_list.empty();
      this.all = {};
      this.current = {
        target : null,
        html : null
      }
      this.default_target = new fb.Target("html > body");
      if (typeof fb.i === "undefined") {
        this.build(this.default_target);
      }
    };
    
    this.remove = function(target_selector, do_not_go_back_to_whole_page) {
      var target = this.all[target_selector];
      target.__unHover();
      if (!do_not_go_back_to_whole_page) {
        if (this.current.html == target.build) {
          fb.i.user_style.populate_fields(this.default_target);
          this.setCurrent(this.default_target);
        }
      }
      if (target.build) {
        target.build.remove(); // delete from the DOM
      }
      target.delete();  // delete the instance of Target
      delete this.all[target_selector];    // delete the reference in list
    };
    
    this.startOver();
    
    self.user_style.your_targets.append(this.target_header);
    self.user_style.your_targets.append($('<div id="outspokes_target_list_wrap"></div>').append(this.target_list));
    self.user_style.your_targets.append(this.target_footer);
    
  };
