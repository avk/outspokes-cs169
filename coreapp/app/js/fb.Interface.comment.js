(function(fb){
  var $ = fb.$;
  
  fb.Interface.comment = function (self) {
    
    this.dom = {
      comment_id_format   : /comment_\d+/i,
      comment_id          : function(id) {
        return (this.comment_id_format.test(id)) ? id : 'comment_' + parseInt(id);
      },
      consensus_wrapper         : function(id) {
        return "consensus_on_comment_" + parseInt(id);
      },
      agree_with                : function(id) {
        return "agree_with_comment_" + parseInt(id);
      },
      disagree_with             : function(id) {
        return "disagree_with_comment_" + parseInt(id);
      },
      agree_bg_color      : '#6F5',
      disagree_bg_color   : 'red',
    }
    
    this.comments = $('<div></div>');
    this.form = $('<div></div>').append(
     '<a href="#">Refresh comments</a>\
      <form name="newcomment" onsubmit="return false;">\
        Comment:<br />\
        <textarea name="content" cols="40" rows="5" /><br />\
        <input type="submit" value="Submit" />&nbsp;&nbsp;<span>Select target</span>\
        <input type="hidden" value="html" name="target" />\
      </form>');
    this.form.find("a").click(function(){fb.Comment.get("render")});
    this.form.find("form").submit(fb.Comment.post);
    this.form.find("span").mouseup(select_target);
    self.main_window.append(this.comments);
    self.main_window.append(this.form);
    
    this.consensus = {
      dom   : this.dom,
      _opinion: function(c_id, color) {
        if (typeof c_id == "string")
          var comment = $('#' + this.dom.comment_id(c_id));
        else
          var comment = c_id;
        comment.css({ 'background-color' : color });
      },
      agree: function(c_id) {
        this._opinion(c_id, this.dom.agree_bg_color);
      },
      disagree: function(c_id) {
        this._opinion(c_id, this.dom.disagree_bg_color);
      },
      build : function(c, markup) {
        if (c.opinion != "") { // this invitee has voted on this comment
          if (c.opinion == 'agreed') {
            this.agree(markup);
          } else if (c.opinion == 'disagreed') {
            this.disagree(markup);
          } else if (c.opinion == 'mine') {
          }
        } else { // this invitee should be allowed to vote on this comment
          var consensus_div = $('<div></div>');
          var agree = this.button(c, 'agree');
          var disagree = this.button(c, 'disagree');
          
          consensus_div[0].setAttribute("id", this.dom.consensus_wrapper(c.feedback_id));
          consensus_div.append(agree);
          consensus_div.append(disagree);
          markup.append(consensus_div);
        }
        return markup;
      },
      button : function(c, action) {
        var button = $('<button type="button">' + action + '</button>');
        button[0].setAttribute("id", eval('this.dom.' + action + '_with(c.feedback_id)'));
        button.click(function() { eval('c.' + action + '()') });
        return button;
      },
    }
    
    this.build = function (c) {
      var rtn = $('<div></div>').css('width','100%');
      rtn[0].setAttribute('id', this.dom.comment_id(c.feedback_id));
      rtn.append(c.name + "<br />");
      rtn.append(c.content + "<br />");
      rtn.append(new Date(c.timestamp) + "<br />");
      
      rtn = this.consensus.build(c, rtn);
      
      rtn.append("<hr style='width:80%' />");
      if (c.target != "html" && c.target != "html > body") {
        var tmp = $(c.target)[0];
        tmp = highlight_target(tmp);
        rtn.hover(tmp[0], tmp[1]);
      }
      return rtn;
    }
    
    this.render = function(c) {
      this.comments.append(c.build);
    }
    
    this.post_failed = function(c){}
    
    this.remove = function(c){
      c.build.remove();
	}
  }
  
  function select_target() {
    $(this).html("Change target");
    $(document.body).one('click', function (e) {
      fb.i.comment.form.find("input[name='target']").attr("value",fb.getPath(e.target));
    });
  }
  
  function highlight_target(el) {
    el = $(el);
    var par = el.wrap("<div></div>").parent();
    over = function() {
      par.css('outline','green solid 3px');
    }
    out = function() {
      par.css('outline-style','none');
    }
    return [over, out];
  }
})(fb_hash);
