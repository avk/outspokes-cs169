var fb = {
	sampleProperty:"Yay!  Code!",
	env:{
		"init":false
	},
	init:function(){
		if (fb.env.init) {
			console.log("Already initialized!");
			return;
		}
		fb.env.init = true;
		console.log("Initialized!");
		return;
	}
};
if (fb.init) {
	fb.init();
}
