


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
	
	static setButtonActor("ButtonActor")		// Taken care of in XML
	
	
	
"*/

class UIButton extends UIComponent
{
	
	// This is set once per scene
	// It will be done in the 
	private static var buttonActor : ActorType = null;
	public static function setButtonActor(actorTypeName : String){
		buttonActor = getActorTypeByName(actorTypeName);
	}
	
	
	
	// UIButton properties
	public var actor : Actor;
	public var isEnabled = true;	// Prevents clicking
	public var originalWidth  : Float;
	public var originalHeight : Float;
	public var currentWidthPerc  : Float = 1;	// 0 to 1
	public var currentHeightPerc : Float = 1;	// 0 to 1
	public var onClick   : Void -> Void;
	public var onRelease : Void -> Void;
	public var hasText = false;
	public var text : String;
	public var font : Font;
	
	public function new(name : String, ?layer : String, ?actorType : ActorType, ?anim : String, ?stl : String){
		if(actorType == null){
			actor = U.createActor(UIButton.buttonActor, layer);
		} else {
			actor = U.createActor(actorType, layer);			
		}
		trace('Supering ${name}');
		super(name, stl);
		inheritsWidth = false;
		inheritsHeight = false;
		if(actor != null){
			if(anim != null) this.setAnimation(anim);
			originalWidth  = actor.getWidth();
			originalHeight = actor.getHeight();
			U.onClick(function(){
				if(!isEnabled || !isShown || onClick == null) return;
				onClick();
			}, actor);
			U.onRelease(function(){
				if(!isEnabled || !isShown || onRelease == null) return;
				onRelease();
			}, actor);
			actor.anchorToScreen();
		} else {
			trace('ERROR: Something went wrong with creating UIButton ${name}');
		}
	}
	
	public function setText(t){
		if(!hasText){
			hasText = true;
			text = t;
			U.onDraw(function(g){
				if(isShown){
					g.drawString(text, x, y);
				}
			});
		} else {
			text = t;
		}		
	}
	
	public override function getWidth(){
		return actor.getWidth();
	}
	
	public override function getHeight(){
		return actor.getHeight();
	}
	
	public override function setWidth(w : Float){
		var perc = w / originalWidth;
		actor.growTo(perc, currentHeightPerc, 0, Easing.linear);
		currentWidthPerc = perc;
	}
	
	public override function setHeight(h : Float){
		var perc = h / originalHeight;
		actor.growTo(currentWidthPerc, perc, 0, Easing.linear);
		currentHeightPerc = perc;
	}
	
	public function markAsGrayed(){
		isEnabled = false;
		actor.setFilter([createSaturationFilter(0)]);
	}
	
	public function unmarkAsGrayed(){
		isEnabled = true;
		actor.clearFilters();
	}
	
	public inline function disable(){
		isEnabled = false;
	}
	
	public inline function enable(){
		isEnabled = true;
	}
	
	public function setAnimation(s : String){
		actor.setAnimation(s);
		originalWidth  = actor.getWidth() / currentWidthPerc;
		originalHeight = actor.getHeight() / currentHeightPerc;
	}
	public function set(s : String){
		setAnimation(s);
	}
	
	public override function hide(){
		if(isShown){
			isShown = false;
			actor.disableActorDrawing();
		}
	}
	public override function show(){
		if(!isShown){
			isShown = true;
			actor.enableActorDrawing();
		}
	}
	
	public override function draw(?frame){
		setupCoordinates(frame);
		if(actor != null){
			actor.setX(x);
			actor.setY(y);
		}
	}
	

}



























