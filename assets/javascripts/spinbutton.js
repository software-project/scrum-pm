
/**
  * Prototype spin button / spin input / number field
  * @Author: wojciech.bajon@mail-from-google
  * @Version: 1.1
  * @reqire: (probably) Prototype 1.6.0.2
  * @basedOn: JQuerySpinBtn.js v1.3a http://www.softwareunity.com/sandbox/jqueryspinbtn/
  * Originally written by George Adamson, Software Unity (george.jquery@softwareunity.com) August 2006.
  * @license: MIT License
  * @Copyright (c) 2008 Wojciech Bajon
  */
  
/**
  * v1.1: reaction on pasate, keyboard function fixes, element from object, not form event
  */
  
  
if(typeof(Prototype) == "undefined")
  throw("spinbutton.js require  prototype library");



/*
 * Orginal: http://adomas.org/javascript-mouse-wheel/
 * prototype extension by "Frank Monnerjahn" <themonnie@gmail.com>
 */
Object.extend(Event, {
  wheel:function (ev){
    var delta = 0;
    if (!ev) ev = window.event;
    if (ev.wheelDelta) {
      delta = ev.wheelDelta/120; 
    } else if (ev.detail) { delta = -ev.detail/3;  }
    return Math.round(delta); //Safari Round
  }
});
/*
 * enf of extension 
 */ 

var SpinButton = Class.create({
    initialize: function(el){
      this.element = $(el);
      if(!this.element)
        return null;
      this.options = Object.extend(
        { ///default options
          min:null,
          max:null,
          step:1,
          page:10,
          spinClass:null,
          upClass:'up',
          downClass:'down',
          reset:Number(this.element.value),
          delay:500,
          interval:100,
          
          _btn_width: 20,
          _btn_height: 12,
          _direction: null,
          _delay: null,
          _repeat: null
        }, arguments[1] || { });
      
      if(this.options.spinClass)
        this.element.addClassName(this.options.spinClass);
      
      Event.observe(this.element,'mousemove',this.onMouseMove.bindAsEventListener(this));
      Event.observe(this.element,'mouseover',this.onMouseMove.bindAsEventListener(this));
      Event.observe(this.element,'mouseout',this.onMouseOut.bindAsEventListener(this));
      if(Prototype.Browser.Gecko){
        Event.observe(this.element,'DOMMouseScroll',this.mousewheel.bindAsEventListener(this),false);
        Event.observe(this.element,'input',this.onChange.bindAsEventListener(this));//FF_pasate
      }else{
        Event.observe(this.element,'mousewheel',this.mousewheel.bindAsEventListener(this),false);
      }
      if(Prototype.Browser.IE){
        Event.observe(this.element,'dblclick',this.onDblClick.bindAsEventListener(this));
        
        var self = this;
        var adjust = function() {
          self.adjustValue(self.options._direction * self.options.step);
        };
        this.element.onpaste= function(){setTimeout(adjust,0);};    
      }
      Event.observe(this.element,'mousedown',this.onMouseDown.bindAsEventListener(this));
      Event.observe(this.element,'mouseup',this.onMouseUp.bindAsEventListener(this));
      Event.observe(this.element,'keydown',this.onKeyDown.bindAsEventListener(this));
      Event.observe(this.element,'change',this.onChange.bindAsEventListener(this));
    },
    onDblClick:function(ev){
      this.adjustValue(this.options._direction * this.options.step);
    },
    onMouseUp:function(ev){
			// Cancel repeating adjustment
			window.clearInterval(this.options._repeat);
			window.clearTimeout(this.options._delay);
    },
    onMouseDown:function(ev){
      if (this.options._direction == 0)
        return;
      var self = this;
      var adjust = function() {
        self.adjustValue(self.options._direction * self.options.step);
      };
    
      adjust();
      
      // Initial delay before repeating adjustment
      self.options._delay = window.setTimeout(function() {
        adjust();
        // Repeat adjust at regular intervals
        self.options._repeat = window.setInterval(adjust, self.options.interval);
      }, self.options.delay);
    },
    onKeyDown:function(ev){
      switch(ev.keyCode){
				case Event.KEY_UP: 
              this.adjustValue(this.options.step); 
              Event.stop(ev); 
          break; 
				case Event.KEY_DOWN: 
              this.adjustValue(-this.options.step);
              Event.stop(ev); 
          break; 
				case Event.KEY_PAGEUP: 
              this.adjustValue(this.options.page);  
              Event.stop(ev);
          break; 
				case Event.KEY_PAGEDOWN:
              this.adjustValue(-this.options.page);
              Event.stop(ev); 
          break; 
			}
    },
    onChange:function(ev){
      this.adjustValue(0);
    },
    adjustValue: function(i){
      var v = (isNaN(this.element.value) ? this.options.reset : Number(this.element.value)) + Number(i);
      if (this.options.min !== null) v = Math.max(v, this.options.min);
      if (this.options.max !== null) v = Math.min(v, this.options.max);
      this.element.value = v;
    },
    onMouseMove:function(ev){
      var of = this.element.cumulativeOffset();// [left, top] 
      var direction = (Event.pointerX(ev) > of[0] + this.element.getWidth() - this.options._btn_width)
        ? ((Event.pointerY(ev) < of[1] + this.options._btn_height) ? 1 : -1) : 0;
        
        if (direction !== this.options._direction) {
        // Style up/down buttons:
        switch(direction){
          case 1: // Up arrow:
            this.element.removeClassName(this.options.downClass).addClassName(this.options.upClass);
            break;
          case -1: // Down arrow:
            this.element.removeClassName(this.options.upClass).addClassName(this.options.downClass);
            break;
          default: // Mouse is elsewhere in the textbox
            this.element.removeClassName(this.options.upClass).removeClassName(this.options.downClass);
        }
        this.options._direction = direction;
        }
    },
    onMouseOut: function(ev){
      this.element.removeClassName(this.options.upClass).removeClassName(this.options.downClass);
    },
    mousewheel:function(ev){
      if(Event.wheel(ev) >= 1)
        this.adjustValue(this.options.step);
      else if(Event.wheel(ev) <= -1)
        this.adjustValue(-this.options.step);
      Event.stop(ev);
    }
});
