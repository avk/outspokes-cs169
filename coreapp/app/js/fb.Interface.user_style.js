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
    
    this.edit_list_link = $('<a href="#">&laquo; List Edits</a>').attr('id', dom.new_edit.link_back);
    this.edit_list_link.click(function() { 
      fb.i.user_style.slide(fb.i.user_style.new_edit_view, fb.i.user_style.edits_view); 
    });
    
    this.your_edits = $('<div>your edits</div>').attr('id', dom.new_edit.your_edits);
    this.your_targets = $('<div>targets</div>').attr('id', dom.new_edit.your_targets);
    
    this.new_edit_view.append(this.edit_list_link);
    this.new_edit_view.append(this.your_edits);
    this.new_edit_view.append(this.your_targets);
    
    // APPEND TO GENERAL INTERFACE  //////////////////////////////////////////////////////////////////
    
    self.edits.append(this.edits_view);
    self.edits.append(this.new_edit_view);
    self.edits.append($('<div style="clear:both;"></div>'));
    
    // var page_edit_new = $('<div></div>').attr('id', dom.new_edit.wrapper);
    // 
    // var target_list_wrapper = $('<div></div>').attr('id', dom.new_edit.target_list.wrapper);
    // target_list_wrapper.append($('<span></span>').append('What you\'re changing').attr('id', dom.new_edit.target_list.header_span));
    // target_list_wrapper.append($('<div></div>').addClass(dom.new_edit.target_list.new_button).append("New Target"));
    // target_list_wrapper.append($('<div></div>').css('clear', 'both'));
    // var target_list = $('<div></div>').attr('id', dom.new_edit.target_list.list);
    // target_list_wrapper.append(target_list);
    // page_edit_new.append(target_list_wrapper);
    // 
    // var middle_panel = $('<div></div>').attr('id', dom.new_edit.middle_panel.panel);
    // var tabs = $('<div></div>').attr('id', dom.new_edit.middle_panel.tabs.tabs);
    // var tabs_ul = $('<ul></ul>');
    // var color_link = $('<li></li>').append($('<span></span>').append('Color'));
    // color_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    // var font_link = $('<li></li>').append($('<span></span>').append('Font'));
    // var copy_link = $('<li></li>').append($('<span></span>').append('Copy'));
    // tabs_ul.append(color_link).append(font_link).append(copy_link);
    // tabs.append(tabs_ul);
    // tabs.append($('<div></div>').css('clear', 'both'));
    // middle_panel.append(tabs);
    // var color_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).show();
    // var color_form = $('<form></form>').append($('<div></div>').addClass(dom.new_edit.middle_panel.content.options_div));
    // var color_form_options_div = color_form.find('div');
    // color_form_options_div.append('<div><span style="float:left;">Background</span><span style="float:right;">#</span></div><div style="clear:both;"></div><br />');
    // color_form_options_div.append('<div><span style="float:left;">Text</span><span style="float:right;">#</span></div><div style="clear:both;"></div>');
    // color_form.append('<input type="text" size="6" /><br />');
    // color_form.append('<input type="text" size="6" /><br />');
    // color_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
    //   '<input type="submit" value="Add" />'));
    // color_content.append(color_form);
    // middle_panel.append(color_content);
    // var font_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).hide();
    // var font_form = $('<form></form>').append($('<div></div>').addClass(dom.new_edit.middle_panel.content.options_div));
    // var font_form_options_div = font_form.find('div');
    // font_form_options_div.append('<div style="float:left;"><div>Font</div><br /><div>Size</div></div>');
    // font_form.append('<input type="text" size="6" /><br />');
    // var font_form_values = $('<div><input type="text" size="6" /></div>');
    // font_form.append(font_form_values);
    // font_form_values.append('<select></select>');
    // font_form_values.find('select').append('<option value="pt">pt</option>');
    // font_form_values.find('select').append('<option value="em">em</option>');
    // font_form_values.find('select').append('<option value="%">%</option>');
    // font_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
    //   '<input type="submit" value="Add" />'));
    // font_content.append(font_form);
    // middle_panel.append(font_content);
    // var copy_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).hide();
    // var copy_form = $('<form></form>');
    // copy_form.append('<textarea></textarea>');
    // copy_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
    //   '<div><input type="button" value="&lt;" style="float: left;" />' +
    //   '<input type="button" value="&gt;" style="float: right;"/></div><br />' +
    //   '<input type="button" value="Delete" /><br />' +
    //   '<input type="submit" value="Add" />'));
    // copy_content.append(copy_form);
    // middle_panel.append(copy_content);
    // page_edit_new.append(middle_panel);
    // 
    // var your_changes_wrapper = $('<div></div>').attr('id', dom.new_edit.your_changes.wrapper);
    // your_changes_wrapper.append($('<span></span>').append('Your changes').attr('id', dom.new_edit.your_changes.header_span));
    // your_changes_wrapper.append($('<div></div>').css('float', 'right').append(
    //   $('<div></div>').addClass(dom.new_edit.your_changes.clear_button).append("Clear")).append(
    //     $('<div></div>').addClass(dom.new_edit.your_changes.submit_button).append("Submit")));
    // your_changes_wrapper.append($('<div></div>').css('clear', 'both'));
    // var your_changes = $('<div></div>').attr('id', dom.new_edit.your_changes.list);
    // your_changes_wrapper.append(your_changes);
    // page_edit_new.append(your_changes_wrapper);
    // 
    // color_link.click(function() {
    //   color_content.show();
    //   font_content.hide();
    //   copy_content.hide();
    //   color_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    //   font_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    //   copy_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    // });
    // font_link.click(function() {
    //   color_content.hide();
    //   font_content.show();
    //   copy_content.hide();
    //   color_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    //   font_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    //   copy_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    // });
    // copy_link.click(function() {
    //   color_content.hide();
    //   font_content.hide();
    //   copy_content.show();
    //   color_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    //   font_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    //   copy_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    // });
    // 
    
    // self.edits.append(page_edit_new);
    // self.edits.append($("<div style='padding: 70px 20px 20px 20px; font-size: 10em; color: #DDD'>Coming Soon</div>"));
  };
  
  // function highlight_target(el_dom) {
  //   var el = $(el_dom);
  //   var old_style = el.css('outline')
  //   var over = function() {
  //     el.css('outline','green solid 2px');
  //   }
  //   var out = function() {
  //     el.css('outline-style', old_style);
  //   }
  //   return [over, out];
  // }
