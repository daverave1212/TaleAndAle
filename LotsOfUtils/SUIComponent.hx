


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

import U.*;
using U;

class SUIComponent
{
	
	public var actorType : ActorType;
	public var actor : Actor;
	public var isShown = true;
	public var originalWidth  : Float;
	public var originalHeight : Float;
	public var currentWidthPerc  : Float = 1;	// 0 to 1
	public var currentHeightPerc : Float = 1;	// 0 to 1
	
	public var data : Dynamic;		// Use this for whatever you want
	
	public function new(actorTypeName : String, layer : String, ?anim : String){
		createLayerIfDoesntExist(layer, 100);
		actorType = getActorTypeByName(actorTypeName);
		actor = createActor(actorTypeName, layer);
		if(actor == null) trace("ERROR: SUIComponent - null actor?");
		if(anim != null) this.setAnimation(anim);
		originalWidth  = actor.getWidth();
		originalHeight = actor.getHeight();
        actor.anchorToScreen();		
	}

    public function getX() return actor.getX();
    public function getY() return actor.getY();
    public function getWidth() return actor.getWidth();
	public function getHeight() return actor.getHeight();
    
    public function setWidth(w : Float){
		var perc = w / originalWidth;
		actor.growTo(perc, currentHeightPerc, 0, Easing.linear);
		currentWidthPerc = perc;
        return this;
	}
	
	public function setHeight(h : Float){
		var perc = h / originalHeight;
		actor.growTo(currentWidthPerc, perc, 0, Easing.linear);
		currentHeightPerc = perc;
        return this;
	}

    public function setX(value : Float){
        actor.anchorToScreen();
		actor.setX(value);
		return this;
	}
	
	public function setY(value : Float){
        actor.anchorToScreen();
		actor.setY(value);
		return this;
	}
	
	public function setLeft(value : Float){
		setX(getScreenX() + value);
		return this;
	}

	public function setLeftFrom(value : Float, offset : Float){
		setX(value + offset);
		return this;
	}
	
	public function setRight(value : Float){
		setX(getScreenX() + getScreenWidth() - getWidth() - value);
		return this;
	}

	public function setRightFrom(value : Float, offset : Float){
		setX(offset - getWidth() - value);
		return this;
	}
	
	public function setTop(value : Float){
		setY(getScreenY() + value);
		return this;
	}

	public function setTopFrom(value : Float, offset : Float){
		setY(value + offset);
		return this;
	}
	
	public function setBottom(value : Float){
		setY(getScreenY() + getScreenHeight() - getHeight() - value);
		return this;
	}

	public function setBottomFrom(value : Float, offset : Float){
		setY(offset - getHeight() - value);
		return this;
	}

	public inline function getBottom() return getY() + getHeight();
	public inline function getRight() return getX() + getWidth();
	public inline function getLeft() return getX();
	public inline function getTop() return getY();

	public inline function centerVertically() setTop(getScreenHeight() / 2 - getHeight() / 2);
	public inline function centerHorizontally() setLeft(getScreenWidth() / 2 - getWidth() / 2);
	

	public function setAnimation(s : String){
		try{
			actor.setAnimation(s);
		} catch (e : String) trace('SUIButton ERROR: Could not load animation: $s');
		originalWidth  = getWidth() / currentWidthPerc;
		originalHeight = getHeight() / currentHeightPerc;
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



























