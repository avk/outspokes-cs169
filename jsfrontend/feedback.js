var fb = {
	// Will hold generated DOM elements
	el:{},
	// Various environment variables
	env:{
		// A boolean indicating if init() had been run yet
		"init":false,
		// A reference to the main <body> tag
		"body":$('body')
	},
	init:function(){
		if (fb.env.init) {
			return;
		}
		fb.el.comment = fb.div().css({
			'border':'thin solid #000000',
			'position':'fixed',
			'top':'0px',
			'left':'0px'});
		fb.el.comment.append($('<img src="comment.png" />'));
		fb.el.main = {}
		fb.el.main.container = fb.div();
		fb.el.main.container.css({
			'display': 'none',
			'border': 'thin solid #000000',
			'position': 'fixed',
			'top': '10px',
			'right': '10px',
			'width': '200px',
			'height': '200px'});
		fb.el.main.close = $('<img src="x.png" />');
		fb.el.main.close.css({
			'position':'absolute',
			'top':'0px',
			'right':'0px',
			'border-left':'thin solid #000000',
			'border-bottom':'thin solid #000000'});
		fb.el.main.container.append(fb.el.main.close);
		fb.el.main.comments = fb.div();
		fb.el.main.container.append(fb.el.main.comments);
		fb.env.body.prepend(fb.el.comment);
		fb.env.body.prepend(fb.el.main.container);
		fb.el.comment.click(fb.comment);
		fb.el.main.close.click(fb.closeComments);

		fb.env.init = true;
		return;
	},

	comment:function(){
		fb.el.main.container.toggle();
		fb.el.main.comments.html('Comments:<br />Yay!  Comments!<br />More comments!<a href="#" onclick="fb.comment2.main();">comment</a>');
		// This should be here in the end.  We don't want to have this div visible
		// during the updates.
		//fb.el.main.container.toggle();
		fb.el.comment.toggle();
		return;
	},

	comment2:{
		main:function(){
			fb.get("http://inst.eecs.berkeley.edu/~jtduncan/test1.js",fb.comment2.callback);
		},
		callback:function(data){
			console.log(data);
			console.log(data.comments[1]);
			console.log(data.field2);
		}
	},

	closeComments:function(){
		fb.el.main.container.toggle();
		fb.el.comment.toggle();
		return;
	},

	// Constructor for an empty div element
	div:function(){
		return $('<div></div>');
	},

	// Get
	get:function(url,callbackFunction){
		$.getJSON(url + "?callback=?",callbackFunction);
	}
};

// Runs fb.init()
// Note, this must be the last call on this page.
fb.init();

