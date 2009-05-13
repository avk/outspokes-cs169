  var $ = fb.$;

  fb.Interface.user_style = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      edits_view : {
        wrapper : "edits_wrap", // id
        edit_id_format   : /edit_\d+/i,
        edit_id          : function(id) {
          return (this.edit_id_format.test(id)) ? id : 'edit_' + parseInt(id);
        },
        number_from_id            : function(dom_id) {
          return parseInt(dom_id.match(/edit_(\d+)/i)[1]);
        },
        consensus_block : "edit_consensus", // class
        consensus_wrapper         : function(id) {
          return "consensus_on_comment_" + parseInt(id);
        },
        agree_with : function(id) { return "agree_with_edit_" + parseInt(id); },
        disagree_with : function(id) {return "disagree_with_edit_" + parseInt(id); },
        
        edit_block : "edit_block", // class
        edit_name : "edit_name", // class
        edit_timestamp : "edit_timestamp", // class
        edits_list : "edits_list", // id
        new_edit_link : "new_edit_link" // id
      },
      
      new_edit : {
        wrapper : "new_edit_wrap",
        link_back : "back_to_edits_list",
        your_edits : "your_edits",
        your_edits_wrapper : "your_edits_wrapper",
        navigation : "your_edits_nav",
        your_targets : "your_targets"
      }
    };
    var dom = this.dom;

    // GENERAL //////////////////////////////////////////////////////////////////

    /**
     * Visual transition from one block-level element to another.
     * from will end up with display : none and width : 0%
     * while to will end up with display : block and width : 100%
     * 
     * @params from - the element being transitioned away from
     * @params to - the hidden, width: 0% element being transitioned to
     */
    this.slide = function(from, to) {
      from.animate(
        { width : '0%' }, // numeric CSS properties
        300, // duration
        null, // N/A
        function() { // callback
          from.hide();
          to.show();
          to.css('width', '100%');
        }
      );
    };
    
    this.refresh_count = function() {
       fb.i.nav.set_label_count(fb.UserStyle.count(), 1);
    };

    // EDITS_VIEW //////////////////////////////////////////////////////////////////

    this.edits_view = $('<div></div>').attr('id', dom.edits_view.wrapper);
    this.edit_list = $('<div></div>').attr('id', dom.edits_view.edits_list);
    this.new_edit_link = $('<div><div>Make your own <span>page edit</span>:<br />Click here! &raquo;</div></div>').attr('id', dom.edits_view.new_edit_link);
    this.new_edit_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.edits_view, fb.i.user_style.new_edit_view); 
    });
    
    // Consensus section
    this.consensus = {
      dom   : this.dom,
      _opinion : function(us_id, consensus_class) {
        var us = null;
        if (typeof us_id == "string") {
          us = $('#' + dom.edit_id(us_id));
        } else {
          us = us_id;
        }
        us.addClass(consensus_class);
      },
      agree: function(us_id) {
        this._opinion(us_id, 'agreed');
      },
      disagree: function(us_id) {
        this._opinion(us_id, 'disagreed');
      },
      build : function(us, markup) {
        if (us.opinion !== "" && !_fb.admin()) { // this invitee has voted on this comment
          if (us.opinion === 'agreed') {
            this.agree(markup);
          } else if (us.opinion == 'disagreed') {
            this.disagree(markup);
          }
        } else { // this invitee should be allowed to vote on this comment
          var us_consensus = $('<div></div>').addClass(dom.edits_view.consensus_block);
          us_consensus.attr("id", dom.edits_view.consensus_wrapper(us.feedback_id));
          var agree = this.button(us, 'agree').addClass('agree');
          var disagree = this.button(us, 'disagree').addClass('disagree');

          agree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});
          disagree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});

          if (_fb.admin()) {
            us_consensus.append($('<span class="agreed">' + us.agreed + '&nbsp;agreed,</span>&nbsp;'));
            us_consensus.append($('<span class="disagreed">' + us.disagreed + '&nbsp;disagreed</span>'));
          } else {
            us_consensus.append(agree);
            us_consensus.append(disagree);
          }

          return us_consensus;
        }
        return "";

      },
      button : function(us, action) {
        var button = $('<button type="button">' + action + '</button>');
        button.attr("id", eval('dom.edits_view.' + action + '_with(us.feedback_id)'));
        button.click(function() { eval('us.' + action + '()'); });
        return button;
      }
    };
    // END consensus section
    
    this.render = function(user_style) {
      this.edit_list.append(this.build(user_style));
    };
    
    this.build = function(user_style) {
      // build up the container for a user style item
      var us_id = dom.edits_view.edit_id(user_style.feedback_id);
      var us_block = $('<div></div>').attr('id', us_id).addClass(dom.edits_view.edit_block);
      
      // define its contents
      var us_checkbox = $('<input type="checkbox" />').addClass('toggle_box');
      us_checkbox.attr('name', 'edit_toggle').attr('value', user_style.feedback_id);
      us_checkbox.click(function() {
        if (this.checked) {
          $('.toggle_box').each(function(){
            this.checked = false;
            $(this).parent().removeClass('active');

            var my_id = dom.edits_view.number_from_id( $(this).parent().attr("id") );
            fb.UserStyle.all[my_id].unapply();
          });
          this.checked = true;
          $(this).parent().addClass('active');

          current_edit = user_style;
          fb.UserStyle.all[user_style.feedback_id].apply();
        } else {
          fb.UserStyle.all[user_style.feedback_id].unapply();
          $(this).parent().removeClass('active');
        }
      });

      var us_name = $('<span></span>').addClass(dom.edits_view.edit_name).append(user_style.name);
      var us_timestamp = $('<span></span>').addClass(dom.edits_view.edit_timestamp).append(fb.get_timestamp(user_style.timestamp));
      
      // attach to the container
      us_block.append(us_checkbox);
      us_block.append(us_name);
      us_block.append(us_timestamp);      
      // us_block.append(this.consensus.build(user_style));
      
      return us_block;
    };

    this.remove = function(user_style) {
      // console.log("Removing from fb.Interface.user_style...");
    };
    
    this.edits_view.append(this.edit_list);
    this.edits_view.append(this.new_edit_link);
    this.edits_view.append($('<div style="clear:both;"></div>'));
    
    
    
    // NEW EDIT //////////////////////////////////////////////////////////////////
    
    this.new_edit_view = $('<div></div>').attr('id', dom.new_edit.wrapper);
    // must start out collapsed and hidden for the slide transitions to work
    this.new_edit_view.css('width','0%'); 
    this.new_edit_view.hide();
    
    // back to list
    this.edit_list_link = $('<a href="#"><br />&laquo;<br />Edits<br />&laquo;</a>').attr('id', dom.new_edit.link_back);
    this.edit_list_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.new_edit_view, fb.i.user_style.edits_view);
      fb.i.target.startOver();
    });
    
    
    
    // NEW_EDIT: YOUR EDITS  //////////////////////////////////////////////////////////////////
    // pane where you pick a style category and set individual properties
    this.your_edits = $('<div></div>').attr('id', dom.new_edit.your_edits);
    this.your_edits.append($('<h1>Your Edits</h1>'));
    this.your_edits_wrapper = $('<div></div>').attr('id', dom.new_edit.your_edits_wrapper);
    this.your_edits.append(this.your_edits_wrapper);
    
    
    
    
    // NEW EDIT: NAVIGATION //////////////////////////////////////////////////////////////////
    
    this.nav = {
      /*
        TO ADD A NEW NAVIGATION ELEMENT: 
        add an entry to elements.labels and elements.content
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
          this.current.removeClass('outspokes-current-edit');
        }
        this.current = this.elements.list[which_element];
        this.current.addClass('outspokes-current-edit');
      },
      
      // ordered set of navigation elements:
      elements : {
        // ordered set of DOM elements
        list : [],
        // the ***singular*** text content of the label
        // same order as list of elements
        labels : [
          'Color',
          'Font'
        ],
        // which content the navigation elements correspond to,
        // these reference variable names in this class (fb.Interface.user_style)
        // same order as list of elements
        content : [
          "your_color",
          "your_font"
        ],
        /*
        clicking on an element:
          makes it the current element
          shows it's content
          hides the content of all the other elements
        */
        click : function(clicked_element, event) {
          for (var which_element = 0; which_element < fb.i.user_style.nav.elements.content.length; which_element++) {
            var content = fb.i.user_style[ fb.i.user_style.nav.elements.content[which_element] ];
            if (clicked_element === fb.i.user_style.nav.elements.list[which_element][0]) {
              fb.i.user_style.nav.setCurrent(which_element);
              content.show();
            } else {
              content.hide();
            }
          }
        }
      },
      
      // creates the bar and returns it
      build : function() {
        this.bar = $('<ul></ul>');
        this.bar.addClass(this.dom.new_edit.navigation);
        
        // builds each element, labels it, and attaches a uniform onclick handler
        for (var which_element = 0; which_element < this.elements.labels.length; which_element++) {
          var element = $('<li></li>');
          
          var label = $('<span></span>');
          label.text( this.elements.labels[which_element] );
          element.append(label);
          
          element.click( function(e) { fb.i.user_style.nav.elements.click(this, e) });
          
          this.elements.list.push(element);
          this.bar.append(element);
        }
        // set first navigation element to current
        this.setCurrent(0);
        
        return this.bar;
      },
    }
    this.your_edits_wrapper.append(this.nav.build());
    this.your_edits_wrapper.append($('<div style="clear:both;"></div>'));
    
    
    
    // NEW EDIT: Color //////////////////////////////////////////////////////////////////
    this.your_color = $('<div></div>').attr('id', 'color_edit_wrap');
    
    var hide_error = function(elem) {
      elem.css('visibility', 'hidden');
    }
    
    var show_error = function(elem) {
     elem.css('visibility', 'visible');
    }
    
    var validate_colorstring = function(str, error_span) {
      if ((str.length > 0) && (! fb.valid_hexstring(str))) {
        show_error(error_span);
        return false;
      } else {
        hide_error(error_span);
        return true;
      }
    };
    
    var apply_color = function(value, key, error_span) {
      if (validate_colorstring(value, error_span) && value.length > 0) {
        fb.i.target.current.target.set_style(key, '#' + value);
      } else if (value.length == 0) {
        fb.i.target.current.target.unset_style(key);
      }
    };
    
    var bgColor = $('<div></div>').attr('id', 'color_bg_edit_wrap');
    var bg_error_message = $('<div class="input_error">Invalid background color:</div>');
    hide_error(bg_error_message);
    bgColor.append(bg_error_message);
    bgColor.append($('<span class="outspokes_edit_label"><label for="outspokes_bgColor" title="Enter a valid hex color value">Background</label></span>' +
      '<span class="pound">#</span><input type="text" id="outspokes_bgColor" name="outspokes_bgColor" />'));
    bgColor.find('input').blur( function() {
      validate_colorstring(this.value, bg_error_message);
    });
    
    var bgColorApply = $('<input class="button" type="submit" value="Apply" title="Apply background color." />');
    bgColorApply.click( function() {
      currBgColor = bgColor.find('input')[0];
      apply_color(currBgColor.value, 'background-color', bg_error_message);
    });
    
    var bgColorRevert = $('<input class="button" type="submit" value="Revert" title="Revert to original background color." />');
    bgColorRevert.click( function() {
      bgColor.find('input')[0].value = "";
      fb.i.target.current.target.unset_style('background-color');
    });
    
    var textColor = $('<div></div>').attr('id', 'color_text_edit_wrap');
    var textcolor_error_message= $('<div class="input_error">Invalid text color:</div>');
    hide_error(textcolor_error_message);
    textColor.append(textcolor_error_message);
    textColor.append($('<span  class="outspokes_edit_label"><label for="outspokes_textColor" title="Enter a valid hex color value">Text</label></span>' + 
      '<span class="pound">#</span><input type="text" id="outspokes_textColor" name="outspokes_textColor" />'));
    textColor.find('input').blur( function() {
      validate_colorstring(this.value, textcolor_error_message);
    });
    
    var textColorApply = $('<input class="button" type="submit" value="Apply" title="Apply text color." />');
    textColorApply.click( function() {
      currTextColor = textColor.find('input')[0];
      apply_color(currTextColor.value, 'color', textcolor_error_message);
    });
    
    var textColorRevert = $('<input class="button" type="submit" value="Revert" title="Revert to original text color." />');
    textColorRevert.click( function() {
      textColor.find('input')[0].value = "";
      fb.i.target.current.target.unset_style('color');
    });
    
    bgColor.append(bgColorApply);
    bgColor.append(bgColorRevert);
    this.your_color.append(bgColor);
    textColor.append(textColorApply);
    textColor.append(textColorRevert);
    this.your_color.append(textColor);
    
    this.your_edits_wrapper.append(this.your_color);
    
    
    
    // NEW EDIT: Font //////////////////////////////////////////////////////////////////
    
    this.your_font = $('<div></div>').attr('id', 'font_edit_wrap');
    this.your_font.hide(); // because it's not the default view

    var fontFamilyOptions = [
      ['Arial', 'sans-serif'],
      ['Arial Black', 'sans-serif'],
      ['Courier New', 'monospace'],
      ['Georgia', 'serif'],
      ['Impact', 'sans-serif'],
      ['Times', 'serif'],
      ['Verdana', 'sans-serif']];
    var fontFamilyOptionObjects = $.map(fontFamilyOptions, function (opt_array, i) {
      var rtn = $('<option></option>');
      rtn.attr('value', opt_array[0]);
      rtn.append(opt_array[0]);
      return rtn;
    });
    console.log(fontFamilyOptions);
    
    var fontFamily = $('<div></div>').attr('id', 'font_family_edit_wrap');
    fontFamily.append('<span class="outspokes_edit_label"><label for="fontFamily">Family</label></span>');
    fontFamily.append('<select name="fontFamily"></select>');
    fontFamily.find('select').append('<option value="" selected="true"></option>');
    $.each(fontFamilyOptionObjects, function (i, opt) {
      fontFamily.find('select').append(opt);
    });
    fontFamily.find('select').change( function() {
      if (this.value == "") {
        fb.i.target.current.target.unset_style('font-family');        
      } else {
        var fontFamilyArray = fontFamilyOptions[this.selectedIndex - 1];
        fb.i.target.current.target.set_style('font-family', fontFamilyArray[0] + ", " + fontFamilyArray[1]);
      }
    });
    
    
    var fontSize = $('<div></div>').attr('id', 'font_size_edit_wrap');
    var font_error_message = $('<div class="input_error">Invalid font size:</div>');
    hide_error(font_error_message);
    fontSize.append(font_error_message);
    fontSize.append($('<span  class="outspokes_edit_label"><label for="outspokes_fontSize" title="Enter a size between 0 and 999">Size</label></span>' +
      '<input type="text" id="outspokes_fontSize" /><span>px</span>'));
    var fontSizeApply = $('<input class="button" type="submit" value="Apply" />');
    var font_size_regex = /^[0-9]{1,3}$/; // precompile this
    // Local helper function for checking font size validity
    function validate_font_size(value) {
      if (value.length > 0 && (! value.match(font_size_regex))) {
        show_error(font_error_message);
        return false;
      } else {
        hide_error(font_error_message);
        return true;
      }
    }
    
    fontSize.find('input').blur(function(e) {
      validate_font_size(this.value);
    });
    fontSizeApply.click( function() {
      currFontSize = fontSize.find('input')[0];
      if (currFontSize.value == "") {
        fb.i.target.current.target.unset_style('font-size');
      } else if (validate_font_size(currFontSize.value)) {
        fb.i.target.current.target.set_style('font-size', currFontSize.value + 'px');        
      }
    });
    
    var fontSizeRevert = $('<input class="button" type="submit" value="Revert" title="Revert to original font size." />');
    fontSizeRevert.click( function() {
      fontSize.find('input')[0].value = "";
      fb.i.target.current.target.unset_style('font-size');
    });

    this.your_font.append(fontFamily);
    fontSize.append(fontSizeApply);
    fontSize.append(fontSizeRevert);
    this.your_font.append(fontSize);

    
    this.your_edits_wrapper.append(this.your_font);
    
    
    
    // NEW EDIT: targeting sidebar  //////////////////////////////////////////////////////////////////
    this.your_targets = $('<div></div>').attr('id', dom.new_edit.your_targets);
    
    
    // NEW EDIT: finishing up  //////////////////////////////////////////////////////////////////
    var your_edits_left_wrapper = $('<div></div>').attr('id', 'your_edits_left_wrapper');
    your_edits_left_wrapper.append(this.edit_list_link);
    your_edits_left_wrapper.append(this.your_edits);
    
    this.new_edit_view.append(your_edits_left_wrapper);
    this.new_edit_view.append(this.your_targets);
    
    
    
    // APPEND TO GENERAL INTERFACE  //////////////////////////////////////////////////////////////////
    
    self.edits.append(this.edits_view);
    self.edits.append(this.new_edit_view);
    self.edits.append($('<div style="clear:both;"></div>'));
    // self.edits.append($("<div style='padding: 70px 20px 20px 20px; font-size: 10em; color: #DDD'>Coming Soon</div>"));
  };
