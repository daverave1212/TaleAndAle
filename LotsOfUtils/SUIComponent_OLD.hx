


import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

import com.stencyl.utils.motion.*;

/*"

"*/

class UIComponent
{
	
	public var parent : UIPanel;
	public var name = "";
	public var x : Float = 0;	// Actual x on screen          these are not used when building the UI
	public var y : Float = 0;	// Actual y on screen          these are not used when building the UI
	
	public var left		: Float = 0;                        // but these are used
	public var right	: Float = 0;                        // but these are used
	public var top		: Float = 0;                        // but these are used
	public var bottom	: Float = 0;                        // but these are used
	private var width  : Float = 0;                  // ONLY use getters and setters for these
	private var height : Float = 0;                  // ONLY use getters and setters for these
	public var inheritsWidth  = true;	// The w of the parent will be used instead of its own
	public var inheritsHeight = true;	// The h of the parent will be used instead of its own
	public var isShown = true;
	public var isContainer = false;
	
	public function propsToString(){
		return '$name $left $right $bottom $top';
	}
	
	// Returns true if it worked, or false if property not found
	public function setProperty(prop : String, val : String){
		var valFloat = Std.parseFloat(val);
		trace('   switch( $prop ) with $val to string $valFloat');
		trace('Length is ${prop.length}');
		trace('bottom == $prop');
		trace("bottom" == prop);
		trace('right == $prop');
		trace("right" == prop);
		switch(prop){
			case "left":	left	= valFloat;  trace('     Did set left $left');
			case "right":	right	= valFloat;  trace('     Did set right $right');
			case "top":		top		= valFloat;  trace('     Did set top $top');
			case "bottom":	bottom	= valFloat;  trace('     Did set bottom $bottom');
			case "width":	setWidth(valFloat);  trace('     Did set ');
			case "height":	setHeight(valFloat); trace('     Did set ');
			default : return false;
		}
		trace('   endswitch $left $right');
		return true;
	}
	
	public function p(prop : String, val : String){
		setProperty(prop, val);
		return this;
	}
	
	
	// 0 prop, 1 value, 2 prop, 3 value, etc...
	function styleFromArray(propsAndVals : Array<String>){
		for(i in 0...propsAndVals.length){
			if(i % 2 == 0) continue;
			var prop = propsAndVals[i-1];
			var val	 = propsAndVals[i];
			trace('For ${name} setting ${prop} to ${val}');
			setProperty(prop, val);
		}
	}
	
	// "color: purple, personality:retarded; "
	public function style(s : String){
		trace('Styling ${name} as ${s}');
		var propsAndVals = U.splitString(s, " \t;,:\n");
		styleFromArray(propsAndVals);
		return this;
	}
	
	
	public function new(n, ?stl){
		name = n;
		if(stl != null){
			style(stl);
		}
	}
	
	public function hide(){
		if(isShown) isShown = false;
	}
	public function show(){
		if(!isShown) isShown = true;
	}
	
	public function setWidth(w){
		width = w;
		inheritsWidth = false;
	}
	
	public function setHeight(h){
		height = h;
		inheritsHeight = false;
	}
	
	public function getWidth() : Float{
		if(inheritsWidth){
			if(parent == null)
				return getScreenWidth();
			else {
				return parent.getWidth() - parent.paddingLeft - parent.paddingRight;
			}
		} else {
			return width;
		}
	}
	public function getHeight() : Float{
		if(inheritsHeight){
			if(parent == null)
				return getScreenHeight();
			else {
				return parent.getHeight() - parent.paddingTop - parent.paddingBottom;
			}
		} else {
			return height;
		}
	}
	
	public function setupCoordinates(?frame){
		if(frame == null) trace('For $name, null frame, so:');
		if(frame == null || parent == null) frame = new Rectangle(0, 0, getScreenWidth(), getScreenHeight());
		trace('For $name, got frame ${frame.toString()}');
		if(bottom == 0){
			y = frame.y + top;
		} else {
			trace('  I do have a bottom $bottom');
			y = frame.y + frame.height - getHeight() - bottom;
		}
		if(right == 0){
			x = frame.x + left;
		} else {
			x = frame.x + frame.width - getWidth() - right;
		}
		trace('  ' + _propsToString());
		trace("  Setup coordinates for " + name + " as " + x + ", " + y);
	}

	public function draw(?frame){
		setupCoordinates(frame);
	}
	
	public function get(childName : String) : UIComponent{
		if(name == childName) return this;
		else return null;
	}
	
	
	
}



























