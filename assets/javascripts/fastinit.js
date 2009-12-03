/*
*
* Copyright (c) 2006 Andrew Tetlaw
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
* * 
*
/*
 * FastInit
 * http://tetlaw.id.au/view/blog/prototype-class-fastinit/
 * Andrew Tetlaw
 * Version 1.2 (2006-10-19)
 * Based on:
 * http://dean.edwards.name/weblog/2006/03/faster
 * http://dean.edwards.name/weblog/2006/06/again/
 * 
 */
var FastInit = {
	done : false,
	onload : function() {
		if (FastInit.done) return;
		FastInit.done = true;
		FastInit.actions.each(function(func) {
			func();
		})
	},
	actions : $A([]),
	addOnLoad : function() {
		for(var x = 0; x < arguments.length; x++) {
			var func = arguments[x];
			if(!func || typeof func != 'function') continue;
			FastInit.actions.push(func);
		}
	}
}

if (/WebKit|khtml/i.test(navigator.userAgent)) {
	var _timer = setInterval(function() {
        if (/loaded|complete/.test(document.readyState)) {
            clearInterval(_timer);
            delete _timer;
            FastInit.onload();
        }
	}, 10);
}
if (document.addEventListener) {
	document.addEventListener('DOMContentLoaded', FastInit.onload, false);
	FastInit.legacy = false;
}

Event.observe(window, 'load', FastInit.onload);


/*@cc_on @*/
/*@if (@_win32)
document.write('<script id="__ie_onload" defer src="javascript:void(0)"><\/script>');
var script = $('__ie_onload');
script.onreadystatechange = function() {
    if (this.readyState == 'complete') {
        FastInit.onload();
    }
};
/*@end @*/
