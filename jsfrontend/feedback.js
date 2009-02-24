var fb = {
	sampleProperty:"Yay!  Code!",
	// Will hold generated DOM elements
	el:{},
	// Various environment variables
	env:{
		// A boolean indicating if init() had been run yet
		"init":false,
		// A reference to the main <body> tag
		"body":$$('body')[0]
	},
	init:function(){
		if (fb.env.init) {
			return;
		}
		fb.el.toggleButton = new Element('div',{'style':'background:#000000;color:#FFFFFF;position:fixed;top:0px;left:0px;'}).update("C");
		fb.el.main = new Element('div',{'style':'background:#000000;color:#FFFFFF;position:fixed;top:0px;right:0px;display:none;'}).update("hello");
		fb.env.body.insert(fb.el.toggleButton);
		fb.env.body.insert(fb.el.main);
		fb.el.toggleButton.observe('click',function(){fb.el.main.toggle();});

		fb.env.init = true;
		return;
	}
};

if (fb.init) {
	fb.init();
}
