// 
// 
//  
// 
// −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−− 
// 
// This is a Greasemonkey user script. 
// 
// To install, you need Greasemonkey: http://greasemonkey.mozdev.org/ 
// Then restart Firefox and revisit this script. 
// Under Tools, there will be a new menu item to "Install User Script". 
// Accept the default configuration and install. 
// 
// To uninstall, go to Tools/Manage User Scripts, 
// select "Hello World", and click Uninstall. 
// 
// −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−− 
// 
// ==UserScript== 
// @name          Outspokes on Google 
// @namespace     http://www.outspokes.com/ 
// @description   script will attach outspokes.com's google include 
// @include       http://*.google.com/* 
// @exclude       http://dontexcludeanything.google.com/* 
// ==/UserScript== 

var headID = document.getElementsByTagName("head")[0];         
var newScript = document.createElement('script');
newScript.type = 'text/javascript';
newScript.src = 'http://beta.outspokes.com/widget/5';
headID.appendChild(newScript);