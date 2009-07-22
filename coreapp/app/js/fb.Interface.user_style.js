  var $ = fb.$;

  fb.Interface.user_style = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      designs_view : {
        wrapper : "designs_wrap", // id
        design_id_format   : /design_\d+/i,
        design_id          : function(id) {
          return (this.design_id_format.test(id)) ? id : 'design_' + parseInt(id);
        },
        number_from_id            : function(dom_id) {
          return parseInt(dom_id.match(/design_(\d+)/i)[1]);
        },
        consensus_block : "design_consensus", // class
        consensus_wrapper         : function(id) {
          return "consensus_on_comment_" + parseInt(id);
        },
        agree_with : function(id) { return "agree_with_design_" + parseInt(id); },
        disagree_with : function(id) {return "disagree_with_design_" + parseInt(id); },
        
        design_block : "outspokes_design_block", // class
        design_name : "outspokes_design_name", // class
        design_timestamp : "outspokes_design_timestamp", // class
        designs_list : "outspokes_designs_list", // id
        new_design_link : "outspokes_new_design_link" // id
      },
      
      new_design : {
        wrapper : "outspokes_new_design_wrap",
        link_back : "outspokes_back_to_designs_list",
        your_designs : "outspokes_your_designs",
        your_designs_wrapper : "outspokes_your_designs_wrapper",
        navigation : "outspokes_your_designs_nav",
        your_targets : "outspokes_your_targets"
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

    // DESIGNS_VIEW //////////////////////////////////////////////////////////////////

    this.new_design_is_current = false;
    this.designs_view = $('<div></div>').attr('id', dom.designs_view.wrapper);
    this.design_list = $('<div></div>').attr('id', dom.designs_view.designs_list);

    this.new_design_link = $('<div>new design &raquo;</div>').attr('id', dom.designs_view.new_design_link);
    this.new_design_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.designs_view, fb.i.user_style.new_design_view);
      fb.i.user_style.unapply_current_design();
      fb.i.user_style.new_design_is_current = true;
    });
    
    // default view for when there are no designs
    this.no_designs = $('<div id="outspokes-no-designs"></div>');
    this.no_designs.append('<span class="outspokes-no-designs-message">Nothing yet</span><br />');
    var call_to_action = $('<span class="outspokes-no-designs-action"></span>');
    if (_fb.admin()) {
      call_to_action.append("How about ");
      invite_link = $('<a href="#">inviting some designers</a>');
      invite_link.click(function() {
        // open up the admin panel and go to the commenters tab
        fb.i.admin_panel.set_to_commenters();
        fb.i.hide_widget();
        fb.i.admin_panel.show();
      });
      call_to_action.append(invite_link);
      call_to_action.append('?');
    } else { // commenter
      call_to_action.append("How do you ")
      design_link = $('<a href="#">want this page to look</a>');
      design_link.click(function() {
        fb.i.user_style.new_design_link.click();
      });
      call_to_action.append(design_link);
      call_to_action.append('?');
    }
    
    this.no_designs.append(call_to_action);
    this.design_list.append(this.no_designs);
    
    
    // Consensus section
    this.consensus = {
      dom   : this.dom,
      _opinion : function(us_id, consensus_class) {
        var us = null;
        if (typeof us_id == "string") {
          us = $('#' + dom.design_id(us_id));
        } else {
          us = us_id;
        }
        us.addClass(consensus_class);
      },
      agree: function(us_id) {
        this._opinion(us_id, 'outspokes_agreed');
      },
      disagree: function(us_id) {
        this._opinion(us_id, 'outspokes_disagreed');
      },
      build : function(us, markup) {
        if (us.opinion !== "" && !_fb.admin()) { // this invitee has voted on this comment
          if (us.opinion === 'agreed') {
            this.agree(markup);
          } else if (us.opinion == 'disagreed') {
            this.disagree(markup);
          }
        } else { // this invitee should be allowed to vote on this comment
          var us_consensus = $('<div></div>').addClass(dom.designs_view.consensus_block);
          us_consensus.attr("id", dom.designs_view.consensus_wrapper(us.feedback_id));
          var agree = this.button(us, 'agree').addClass('outspokes_agree');
          var disagree = this.button(us, 'disagree').addClass('outspokes_disagree');

          agree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});
          disagree.hover(function(){$(this).addClass('hover');},function(){$(this).removeClass('hover');});

          if (_fb.admin()) {
            us_consensus.append($('<span class="outspokes_agreed">' + us.agreed + '&nbsp;agreed,</span>&nbsp;'));
            us_consensus.append($('<span class="outspokes_disagreed">' + us.disagreed + '&nbsp;disagreed</span>'));
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
        button.attr("id", eval('dom.designs_view.' + action + '_with(us.feedback_id)'));
        button.click(function() { eval('us.' + action + '()'); });
        return button;
      }
    };
    // END consensus section
    
    this.render = function(user_style) {
      // remove the default no designs message because there's an design to render
      this.no_designs.remove();
      this.design_list.append(this.build(user_style));
    };

    var current_clicked = null;
    this.build = function(user_style) {
      // build up the container for a user style item
      var us_id = dom.designs_view.design_id(user_style.feedback_id);
      var us_block = $('<div></div>').attr('id', us_id).addClass(dom.designs_view.design_block);
      
      // define its contents
      us_block.click(function() {
        if (!$(this).hasClass('active')) { // currently not active
          $('.' + dom.designs_view.design_block).each(function(){ // for other design
            // this.checked = false;
            $(this).removeClass('active');
            var my_id = dom.designs_view.number_from_id( $(this).attr("id") );
            fb.UserStyle.all[my_id].unapply();
          });
          // this.checked = true;
          $(this).addClass('active');

          fb.UserStyle.all[user_style.feedback_id].apply();
          current_clicked = $(this);
        } else {
          fb.UserStyle.all[user_style.feedback_id].unapply();
          $(this).removeClass('active');
          current_clicked = null;
        }
      });

      var us_name = $('<span></span>').addClass(dom.designs_view.design_name).append(user_style.name);
      var us_timestamp = $('<span></span>').addClass(dom.designs_view.design_timestamp).append(fb.get_timestamp(user_style.timestamp));
      
      // attach to the container
      us_block.append(us_name);
      us_block.append(us_timestamp);      
      // us_block.append(this.consensus.build(user_style));
      
      return us_block;
    };

    this.unapply_current_design = function () {
      if (current_clicked === null) {
        return;
      }
      current_clicked.click();
      current_clicked = null;
    };

    this.remove = function(user_style) {
      // console.log("Removing from fb.Interface.user_style...");
    };
    
    this.designs_view.append(this.design_list);
    this.designs_view.append(this.new_design_link);    
    
    // NEW DESIGN //////////////////////////////////////////////////////////////////
    
    this.new_design_view = $('<div></div>').attr('id', dom.new_design.wrapper);
    // must start out collapsed and hidden for the slide transitions to work
    this.new_design_view.css('width','0%'); 
    this.new_design_view.hide();

    this.hide_new_design_view = function () {
      if (fb.i.target.changes_to_targets(true)) {
        var answer = confirm("This will undo all of your changes and clear all your selected targets.  Are you sure?");
        if (!answer) {return;}
      }
      
      fb.i.user_style.slide(fb.i.user_style.new_design_view, fb.i.user_style.designs_view);
      fb.i.user_style.new_design_is_current = false;
      fb.i.target.startOver();
      return true;
    };
    
    // back to list
    this.design_list_link = $('<a>&laquo; list</a>').attr('id', dom.new_design.link_back);
    this.design_list_link.click(this.hide_new_design_view);
    
    
    // NEW_DESIGN: YOUR DESIGNS  //////////////////////////////////////////////////////////////////
    // pane where you pick a style category and set individual properties
    this.your_designs = $('<div></div>').attr('id', dom.new_design.your_designs);
    //this.your_designs.append($('<h1>Your designs</h1>'));
    this.your_designs_wrapper = $('<div></div>').attr('id', dom.new_design.your_designs_wrapper);
    this.your_designs.append(this.your_designs_wrapper);
    
    
    
    
    // NEW DESIGN: NAVIGATION //////////////////////////////////////////////////////////////////
    
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
          this.current.removeClass('outspokes-current-design');
        }
        this.current = this.elements.list[which_element];
        this.current.addClass('outspokes-current-design');
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
        this.bar.addClass(this.dom.new_design.navigation);
        
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
    this.your_designs_wrapper.append(this.nav.build());
    
    
    
    // NEW DESIGN: Color //////////////////////////////////////////////////////////////////
    this.your_color = $('<div></div>').attr('id', 'outspokes_color_design_wrap');
    
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

    // And array of tuples, the first element being the DOM elements of every
    // input field (needed for propagation/reset), and the second being the
    // names of the CSS properties they are associated with.
    var design_fields = [];
    var value_type = {
      'background-color': 'hash_color',
      'color': 'hash_color',
      'font-family': 'string',
      'font-size': 'number'
    };
    
    var bgColor = $('<div></div>').attr('id', 'outspokes_color_bg_design_wrap');
    var bg_error_message = $('<div class="outspokes_input_error">Invalid background color:</div>');
    hide_error(bg_error_message);
    // bgColor.append(bg_error_message);
    bgColor.append($('<label class="outspokes_design_label" for="outspokes_bgColor" title="Enter a valid hex color value">Background</label>' +
      '<span class="outspokes_pound">#</span><input type="text" id="outspokes_bgColor" name="outspokes_bgColor" />'));
    bgColor.find('input').blur( function() {
      validate_colorstring(this.value, bg_error_message);
    });
    design_fields.push([bgColor.find('input')[0], 'background-color']);
    
    var bgColorApply = $('<input class="outspokes_button" type="submit" value="Apply" title="Apply background color." />');
    bgColorApply.click( function() {
      currBgColor = bgColor.find('input')[0];
      apply_color(currBgColor.value, 'background-color', bg_error_message);
    });
    
    var bgColorRevert = $('<input class="outspokes_button" type="submit" value="Revert" title="Revert to original background color." />');
    bgColorRevert.click( function() {
      fb.i.target.current.target.unset_style('background-color');
      bgColor.find('input')[0].value = get_background_color(fb.i.target.current.target);
    });
    
    var textColor = $('<div></div>').attr('id', 'outspokes_color_text_design_wrap');
    var textcolor_error_message= $('<div class="outspokes_input_error">Invalid text color:</div>');
    hide_error(textcolor_error_message);
    // textColor.append(textcolor_error_message);
    textColor.append($('<label class="outspokes_design_label" for="outspokes_textColor" title="Enter a valid hex color value">Text</label>' + 
      '<span class="pound">#</span><input type="text" id="outspokes_textColor" name="outspokes_textColor" />'));
    textColor.find('input').blur( function() {
      validate_colorstring(this.value, textcolor_error_message);
    });
    design_fields.push([textColor.find('input')[0], 'color']);
    
    var textColorApply = $('<input class="outspokes_button" type="submit" value="Apply" title="Apply text color." />');
    textColorApply.click( function() {
      currTextColor = textColor.find('input')[0];
      apply_color(currTextColor.value, 'color', textcolor_error_message);
    });
    
    var textColorRevert = $('<input class="outspokes_button" type="submit" value="Revert" title="Revert to original text color." />');
    textColorRevert.click( function() {
      fb.i.target.current.target.unset_style('color');
      textColor.find('input')[0].value = rgb_to_hash(fb.i.target.current.target.current_style('color'));
    });
    
    bgColor.append(bgColorApply);
    bgColor.append(bgColorRevert);
    this.your_color.append(bg_error_message);
    this.your_color.append(bgColor);
    textColor.append(textColorApply);
    textColor.append(textColorRevert);
    this.your_color.append(textcolor_error_message);
    this.your_color.append(textColor);
    
    this.your_designs_wrapper.append(this.your_color);
    
    
    
    // NEW DESIGN: Font //////////////////////////////////////////////////////////////////
    
    this.your_font = $('<div></div>').attr('id', 'outspokes_font_design_wrap');
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
    
    var fontFamily = $('<div></div>').attr('id', 'outspokes_font_family_design_wrap');
    fontFamily.append('<label class="outspokes_design_label" for="fontFamily">Family</label>');
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
    design_fields.push([fontFamily.find('select')[0], 'font-family']);
    
    
    var fontSize = $('<div></div>').attr('id', 'outspokes_font_size_design_wrap');
    var font_error_message = $('<div class="outspokes_input_error">Invalid font size:</div>');
    hide_error(font_error_message);
    // fontSize.append(font_error_message);
    fontSize.append($('<label class="outspokes_design_label" for="outspokes_fontSize" title="Enter a size between 0 and 999">Size</label>' +
      '<input type="text" id="outspokes_fontSize" /><span>px</span>'));
    var fontSizeApply = $('<input class="outspokes_button" type="submit" value="Apply" />');
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
    design_fields.push([fontSize.find('input')[0], 'font-size']);
    fontSizeApply.click( function() {
      currFontSize = fontSize.find('input')[0];
      if (currFontSize.value == "") {
        fb.i.target.current.target.unset_style('font-size');
      } else if (validate_font_size(currFontSize.value)) {
        fb.i.target.current.target.set_style('font-size', currFontSize.value + 'px');     
      }
    });
    
    var fontSizeRevert = $('<input class="outspokes_button" type="submit" value="Revert" title="Revert to original font size." />');
    fontSizeRevert.click( function() {
      fb.i.target.current.target.unset_style('font-size');
      fontSize.find('input')[0].value = parseInt(fb.i.target.current.target.current_style('font-size'), 10).toString(10);;
    });

    this.your_font.append(fontFamily);
    fontSize.append(fontSizeApply);
    fontSize.append(fontSizeRevert);
    this.your_font.append(font_error_message);
    this.your_font.append(fontSize);

    this.your_designs_wrapper.append(this.your_font);

    this.populate_fields = function (target) {
      var element, property;
      var val, wanted_type;
      $.each(design_fields, function (i, tuple) {
        element = tuple[0];
        property = tuple[1];
        val = target.current_style(property);
        wanted_type = value_type[property];
        if (property === 'background-color') {
          val = get_background_color(target);
          wanted_type = "";
        }
        switch (wanted_type) {
          case 'hash_color':
            val = rgb_to_hash(val);
            break;
          case 'string':
            break;
          case 'number':
            val = parseInt(val, 10).toString(10);
            break;
          default:
            break;
        }
        element.value = "";
        element.value = val;
      });
    };

    function get_background_color(target) {
      var val = target.current_style('background-color');
      var el = target.element;
      val = rgb_to_hash(val);
      while (val === "" && el[0] !== document.documentElement) {
        el = el.parent();
        val = rgb_to_hash(get_style(el, 'background-color'));
      }
      if (val === "") {
        val = "ffffff";
      }
      return val.toUpperCase();
    }

    function get_style(element, property) {
      if (element.jquery !== 'undefined') {
        element = element[0]; 
      }
      return window.getComputedStyle(element, null).getPropertyValue(property);
    }

    function rgb_to_hash(str) {
      if (!/rgb/.test(str)) {
        return "";
      }

      // Firefox: rgb(0, 0, 0)
      // Safari:  rgba(0, 0, 0, 0)
      var rgbStr = /rgba?\((\d{1,3}), (\d{1,3}), (\d{1,3}).*\)/.exec(str);
      if (!rgbStr) {
        console.log("ERROR: Unable to match rgbStr for userStyle");
      }
      var rgb = rgbStr.slice(1, 4);
      var rtn = "";
      $.each(rgb, function (i, val) {
        rtn += pad_to_length_2(parseInt(val, 10).toString(16));
      });
      return rtn.toUpperCase();
    }

    function pad_to_length_2 (str) {
      if (str.length > 2) {
        return str.slice(0, 2);
      }
      while (str.length < 2) {
        str = "0" + str;
      }
      return str;
    }

    // NEW DESIGN: targeting sidebar  //////////////////////////////////////////////////////////////////
    this.your_targets = $('<div></div>').attr('id', dom.new_design.your_targets);
    
    
    // NEW DESIGN: finishing up  //////////////////////////////////////////////////////////////////
    var your_designs_left_wrapper = $('<div></div>').attr('id', 'outspokes_your_designs_left_wrapper');
    // your_designs_left_wrapper.append(this.design_list_link);
    your_designs_left_wrapper.append(this.your_designs);
    this.new_design_view.append(this.your_targets);   
    this.new_design_view.append(your_designs_left_wrapper);
    this.new_design_view.append(this.design_list_link);

    
    
    
    // APPEND TO GENERAL INTERFACE  //////////////////////////////////////////////////////////////////
    
    self.designs.append(this.designs_view);
    self.designs.append(this.new_design_view);
    self.designs.append($('<div style="clear:both;"></div>'));
    // self.designs.append($("<div style='padding: 70px 20px 20px 20px; font-size: 10em; color: #DDD'>Coming Soon</div>"));
  };
