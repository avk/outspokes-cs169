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
        edit_block : "edit_block", // class
        edit_name : "edit_name", // class
        edit_timestamp : "edit_timestamp", // class
        consensus_block : "edit_consensus", // class
        agree_with : function() {  },
        disagree_with : function() { },

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
    }

    // EDITS_VIEW //////////////////////////////////////////////////////////////////

    this.edits_view = $('<div></div>').attr('id', dom.edits_view.wrapper);
    this.edit_list = $('<div></div>').attr('id', dom.edits_view.edits_list);
    this.new_edit_link = $('<a href="#">New Edit &raquo;</a>').attr('id', dom.edits_view.new_edit_link);
    this.new_edit_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.edits_view, fb.i.user_style.new_edit_view); 
    });
    
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
      var us_name = $('<span></span>').addClass(dom.edits_view.edit_name).append(user_style.name);
      var us_timestamp = $('<span></span>').addClass(dom.edits_view.edit_timestamp).append(fb.get_timestamp(user_style.timestamp));
      var us_consensus = $('<div></div>').addClass(dom.edits_view.consensus_block);
      var agree_button = $('<button type="button" class="agree">agree</button>');
      var disagree_button = $('<button type="button" class="disagree">disagree</button>');
      
      // attach to the container
      us_block.append(us_checkbox);
      us_block.append(us_name);
      us_block.append(us_timestamp);
      
      // Put the consensus buttons in the consensus block
      us_consensus.append(agree_button);
      us_consensus.append(disagree_button);
      
      us_block.append(us_consensus);
      
      return us_block;
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
    this.edit_list_link = $('<a href="#">&laquo; List Edits</a>').attr('id', dom.new_edit.link_back);
    this.edit_list_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.new_edit_view, fb.i.user_style.edits_view); 
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
    this.your_color = $('<div></div>');
    
    var bgColor = $('<label for="bgColor">Background</label><span class="pound">#</span><input type="text" name="bgColor" /><br />');
    var textColor = $('<label for="textColor">Text</label><span class="pound">#</span><input type="text" name="textColor" /><br />');
    
    this.your_color.append(bgColor);
    this.your_color.append(textColor);
    
    this.your_edits_wrapper.append(this.your_color);
    
    
    
    // NEW EDIT: Font //////////////////////////////////////////////////////////////////
    this.your_font = $('<div></div>');
    this.your_font.hide(); // because it's not the default view
    
    var fontFamily = $('<label for="fontFamily">Family</label><input type="text" name="fontFamily" /><br />');
    var fontSize = $('<label for="fontSize">Size</label><input type="text" name="fontSize" /><span>px</span><br />');
    
    this.your_font.append(fontFamily);
    this.your_font.append(fontSize);
    
    this.your_edits_wrapper.append(this.your_font);
    
    
    
    // NEW EDIT: targeting sidebar  //////////////////////////////////////////////////////////////////
    this.your_targets = $('<div>targets</div>').attr('id', dom.new_edit.your_targets);
    
    
    
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
