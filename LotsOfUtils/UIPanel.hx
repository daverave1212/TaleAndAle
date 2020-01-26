


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
	.paddingLeft   = _
	.paddingRight  = _
	.paddingTop	   = _
	.paddingBottom = _
	.setPadding(_)			// sets all paddings
	
	.setBorderColor('FFFFFF')
	
	.addChild(UIComponent)
	
	
"*/

class UIPanel extends UIComponent
{
	
	public var children			: Array<UIComponent>;
	public var childrenByName	: Map<String, UIComponent>;
	
	public var paddingLeft	 : Float = 0;
	public var paddingRight	 : Float = 0;
	public var paddingTop	 : Float = 0;
	public var paddingBottom : Float = 0;
	
	public var hasBorder = false;
	private var borderColor = -1;	// ONLY set it with setBorderColor("FFFFFF")
	
	public var lastAddedChild : UIComponent = null;
	

	
	public function setBorderColor(c : String){
		borderColor = U.getColor(c);
		trace("Set border color to " + borderColor);
		hasBorder = true;
	}
	
	private function drawBorder(g : G){			// Used in constructor
		if(hasBorder && borderColor != -1 && isShown){
			g.strokeSize = 3;
			g.strokeColor = borderColor;
			g.drawRect(x, y, getWidth(), getHeight());
		}
	}
	
	public function new(name, ?stl : String){
		isContainer = true;
		super(name, stl);
		children = [];
		childrenByName = new Map<String, UIComponent>();
		U.onDraw(function(g:G){
			drawBorder(g);
		});
	}
	
	public override function hide(){
		if(isShown){
			isShown = false;
			for(c in children){
				c.hide();
			}
		}
	}
	public override function show(){
		if(!isShown){
			isShown = true;
			for(c in children){
				c.show();
			}
		}
	}
	
	public function setPadding(x){
		paddingBottom = x;
		paddingLeft = x;
		paddingRight = x;
		paddingTop = x;
	}
	
	public function addChild(child : UIComponent){
		if(child == null) return;
		children.push(child);
		childrenByName[child.name] = child;
		child.parent = this;
		lastAddedChild = child;
	}
	
	public function add(?child : UIComponent, ?_children : Array<UIComponent>){
		if(child != null){
			addChild(child);
		}
		if(_children != null){
			for(c in _children){
				addChild(c);
			}
		}
	}
	
	private function getFrame(){
		var myFrame = new Rectangle(
			x + paddingLeft,
			y + paddingTop,
			getWidth() - paddingLeft - paddingRight,
			getHeight() - paddingTop - paddingBottom
		);
		return myFrame;
	}

	
	public override function draw(?frame){
		setupCoordinates(frame);
		var myFrame = getFrame();
		for(i in 0...children.length){
			children[i].draw(myFrame);
		}
	}
	
	public override function setProperty(prop : String, val : String){
		trace("Setting property " + prop);
		var wasNormalProperty = super.setProperty(prop, val);
		if(!wasNormalProperty){
			var valFloat = Std.parseFloat(val);
			switch(prop){
				case "padding" 			: setPadding(valFloat);
				case "padding-left"		: paddingLeft = valFloat;
				case "padding-top"		: paddingTop = valFloat;
				case "padding-right"	: paddingRight = valFloat;
				case "padding-bottom"	: paddingBottom = valFloat;
				case "border-color"		: setBorderColor(val);
				default: return false;
			}
		}
		return true;
	}
	
	public override function get(childName : String) : UIComponent{
		if(name == childName){
			return this;
		} else {
			for(c in children){
				var ret = c.get(childName);
				if(ret != null) return ret;
			}
			return null;
		}
	}
	
}



























