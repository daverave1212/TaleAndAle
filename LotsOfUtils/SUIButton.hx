


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

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

import U.*;
using U;

/*"

	API:
		new("ActorTypeName", "layerName", ?"animationName")

		.isEnabled		.enable() / .disable()
		.isShown		.show() / .hide()

		.markAsGrayed()	/ .unmarkAsGrayed()

		.setLeft(_)
		.setRight(_)
		.setTop(_)
		.setBottom(_)
		.setWidth(_)
		.setHeight(_)
		.getWidth(_)
		.getHeight(_)

	
"*/

class SUIButton
{
	
	
	
	// UIButton properties
	public var actorType : ActorType;
	public var actor : Actor;
	public var isEnabled = true;	// Prevents clicking
	public var isShown   = true;
	public var originalWidth  : Float;
	public var originalHeight : Float;
	public var currentWidthPerc  : Float = 1;	// 0 to 1
	public var currentHeightPerc : Float = 1;	// 0 to 1
	public var click   : Void -> Void;
	public var release : Void -> Void;
	public var hasText = false;
	public var text : String;
	public var font : Font;
	
	
	public var data : Dynamic;		// Use this for whatever you want
	
	public function new(actorTypeName : String, layer : String, ?anim : String){
		createLayerIfDoesntExist(layer, 100);
		actorType = getActorTypeByName(actorTypeName);
		actor = createActor(actorTypeName, layer);
		if(actor == null) trace("ERROR: SUIButton - null actor?");
		if(anim != null) this.setAnimation(anim);
		originalWidth  = actor.getWidth();
		originalHeight = actor.getHeight();
		onClick(function(){
			if(isEnabled && isShown && click != null)
				click();
		}, actor);
		onRelease(function(){
			if(isEnabled && isShown && release != null)
				release();
		}, actor);
		actor.anchorToScreen();
	}
	
	public function setText(t){
		// TODO
	}
	
	public function setLeft(value : Float){
		actor.unanchorFromScreen();
		actor.setX(getScreenX() + value);
		actor.anchorToScreen();
	}

	public function setLeftFrom(value : Float, offset : Float){
		actor.unanchorFromScreen();
		actor.setX(value + offset);
		actor.anchorToScreen();
	}
	
	public function setRight(value : Float){
		actor.unanchorFromScreen();
		actor.setX(getScreenX() + getScreenWidth() - getWidth() - value);
		actor.anchorToScreen();
	}

	public function setRightFrom(value : Float, offset : Float){
		actor.unanchorFromScreen();
		actor.setX(offset - getWidth() - value);
		actor.anchorToScreen();
	}
	
	public function setTop(value : Float){
		actor.unanchorFromScreen();
		actor.setY(getScreenY() + value);
		actor.anchorToScreen();
	}

	public function setTopFrom(value : Float, offset : Float){
		actor.unanchorFromScreen();
		actor.setY(value + offset);
		actor.anchorToScreen();
	}
	
	public function setBottom(value : Float){
		actor.unanchorFromScreen();
		actor.setY(getScreenY() + getScreenHeight() - getHeight() - value);
		actor.anchorToScreen();
	}

	public function setBottomFrom(value : Float, offset : Float){
		actor.unanchorFromScreen();
		actor.setY(offset - getHeight() - value);
		actor.anchorToScreen();
	}
	
	public function setX(value : Float){
		actor.unanchorFromScreen();
		actor.setX(value);
		actor.anchorToScreen();
	}
	
	public function setY(value : Float){
		actor.unanchorFromScreen();
		actor.setY(value);
		actor.anchorToScreen();
	}
	
	public function getWidth(){
		return actor.getWidth();
	}
	
	public function getHeight(){
		return actor.getHeight();
	}
	
	public function setWidth(w : Float){
		var perc = w / originalWidth;
		actor.growTo(perc, currentHeightPerc, 0, Linear.easeNone);
		currentWidthPerc = perc;
	}
	
	public function setHeight(h : Float){
		var perc = h / originalHeight;
		actor.growTo(currentWidthPerc, perc, 0, Linear.easeNone);
		currentHeightPerc = perc;
	}
	
	public function disableAndMarkAsGrayed(){
		isEnabled = false;
		actor.setFilter([createSaturationFilter(0)]);
	}

	public function enableAndUnmarkAsGrayed(){
		isEnabled = true;
		actor.clearFilters();
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
		try{
			actor.setAnimation(s);
		} catch (e : String) trace('SUIButton ERROR: Could not load animation: $s');
		originalWidth  = actor.getWidth() / currentWidthPerc;
		originalHeight = actor.getHeight() / currentHeightPerc;
	}
	public function set(s : String){
		setAnimation(s);
	}
	
	public function hide(){
		if(isShown){
			isShown = false;
			actor.disableActorDrawing();
		}
	}
	public function show(){
		if(!isShown){
			isShown = true;
			actor.enableActorDrawing();
		}
	}
	

}



























