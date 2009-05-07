  var $ = fb.$;

  fb.Interface.page_edit = function (self) {
    
    // Common identifiers used in this interface
    this.dom = {
      new_edit : {
        wrapper : 'page_edit_new',
        target_list: {
          wrapper : 'target_list_wrapper',
          header_span : 'changing',
          list : 'target_list',
          new_button : 'new_button'    // class
        },
        middle_panel: {
          panel : 'middle_panel',
          tabs : {
            tabs : 'tabs',
            current : 'current'    // class
          },
          content : {
            content : 'content',     // class
            options_div : 'options_div',  // class
            button_panel : 'button_panel' // class
          }
        },
        your_changes: {
          wrapper : 'your_changes_wrapper',
          header_span : 'your_changes_header',
          list : 'your_changes',
          clear_button : 'clear_button',    // class
          submit_button : 'submit_button'  // class
        }
      }
    };
    var dom = this.dom;

    var page_edit_new = $('<div></div>').attr('id', dom.new_edit.wrapper);

    var target_list_wrapper = $('<div></div>').attr('id', dom.new_edit.target_list.wrapper);
    target_list_wrapper.append($('<span></span>').append('What you\'re changing').attr('id', dom.new_edit.target_list.header_span));
    target_list_wrapper.append($('<div></div>').addClass(dom.new_edit.target_list.new_button).append("New Target"));
    target_list_wrapper.append($('<div></div>').css('clear', 'both'));
    var target_list = $('<div></div>').attr('id', dom.new_edit.target_list.list);
    target_list_wrapper.append(target_list);
    page_edit_new.append(target_list_wrapper);

    var middle_panel = $('<div></div>').attr('id', dom.new_edit.middle_panel.panel);
    var tabs = $('<div></div>').attr('id', dom.new_edit.middle_panel.tabs.tabs);
    var tabs_ul = $('<ul></ul>');
    var color_link = $('<li></li>').append($('<span></span>').append('Color'));
    color_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    var font_link = $('<li></li>').append($('<span></span>').append('Font'));
    var copy_link = $('<li></li>').append($('<span></span>').append('Copy'));
    tabs_ul.append(color_link).append(font_link).append(copy_link);
    tabs.append(tabs_ul);
    tabs.append($('<div></div>').css('clear', 'both'));
    middle_panel.append(tabs);
    var color_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).show();
    var color_form = $('<form></form>').append($('<div></div>').addClass(dom.new_edit.middle_panel.content.options_div));
    var color_form_options_div = color_form.find('div');
    color_form_options_div.append('<div><span style="float:left;">Background</span><span style="float:right;">#</span></div><div style="clear:both;"></div><br />');
    color_form_options_div.append('<div><span style="float:left;">Text</span><span style="float:right;">#</span></div><div style="clear:both;"></div>');
    color_form.append('<input type="text" size="6" /><br />');
    color_form.append('<input type="text" size="6" /><br />');
    color_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
      '<input type="submit" value="Add" />'));
    color_content.append(color_form);
    middle_panel.append(color_content);
    var font_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).hide();
    var font_form = $('<form></form>').append($('<div></div>').addClass(dom.new_edit.middle_panel.content.options_div));
    var font_form_options_div = font_form.find('div');
    font_form_options_div.append('<div style="float:left;"><div>Font</div><br /><div>Size</div></div>');
    font_form.append('<input type="text" size="6" /><br />');
    var font_form_values = $('<div><input type="text" size="6" /></div>');
    font_form.append(font_form_values);
    font_form_values.append('<select></select>');
    font_form_values.find('select').append('<option value="pt">pt</option>');
    font_form_values.find('select').append('<option value="em">em</option>');
    font_form_values.find('select').append('<option value="%">%</option>');
    font_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
      '<input type="submit" value="Add" />'));
    font_content.append(font_form);
    middle_panel.append(font_content);
    var copy_content = $('<div></div>').addClass(dom.new_edit.middle_panel.content.content).hide();
    var copy_form = $('<form></form>');
    copy_form.append('<textarea></textarea>');
    copy_form.append($('<div></div>').addClass(dom.new_edit.middle_panel.content.button_panel).append(
      '<div><input type="button" value="&lt;" style="float: left;" />' +
      '<input type="button" value="&gt;" style="float: right;"/></div><br />' +
      '<input type="button" value="Delete" /><br />' +
      '<input type="submit" value="Add" />'));
    copy_content.append(copy_form);
    middle_panel.append(copy_content);
    page_edit_new.append(middle_panel);

    var your_changes_wrapper = $('<div></div>').attr('id', dom.new_edit.your_changes.wrapper);
    your_changes_wrapper.append($('<span></span>').append('Your changes').attr('id', dom.new_edit.your_changes.header_span));
    your_changes_wrapper.append($('<div></div>').css('float', 'right').append(
      $('<div></div>').addClass(dom.new_edit.your_changes.clear_button).append("Clear")).append(
        $('<div></div>').addClass(dom.new_edit.your_changes.submit_button).append("Submit")));
    your_changes_wrapper.append($('<div></div>').css('clear', 'both'));
    var your_changes = $('<div></div>').attr('id', dom.new_edit.your_changes.list);
    your_changes_wrapper.append(your_changes);
    page_edit_new.append(your_changes_wrapper);

    color_link.click(function() {
      color_content.show();
      font_content.hide();
      copy_content.hide();
      color_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
      font_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
      copy_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    });
    font_link.click(function() {
      color_content.hide();
      font_content.show();
      copy_content.hide();
      color_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
      font_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
      copy_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
    });
    copy_link.click(function() {
      color_content.hide();
      font_content.hide();
      copy_content.show();
      color_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
      font_link.find('span').removeClass(dom.new_edit.middle_panel.tabs.current);
      copy_link.find('span').addClass(dom.new_edit.middle_panel.tabs.current);
    });

//  NOTE: Uncomment these lines to make this interface take over the widget_content div
//    (this is a workaround since the rest of the interface doesn't exist).
   // self.widget_content.empty();
   // self.widget_content.append(page_edit_new);
    
  };
  
  function highlight_target(el_dom) {
    var el = $(el_dom);
//    var par = el.wrap("<div></div>").parent();
    var old_style = el.css('outline')
    var over = function() {
      el.css('outline','green solid 2px');
    }
    var out = function() {
      el.css('outline-style', old_style);
    }
    return [over, out];
  }
