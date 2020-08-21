


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

/*"

	API:
		new("ActorTypeName", "layerName", ?"animationName")

		.isEnabled		.enable() / .disable()
		.isShown		.show() / .hide()
		.disableAndMarkAsGrayed()
		.enableAndUnmarkAsGrayed()

		.click = function() : Void ...

		.markAsGrayed()	/ .unmarkAsGrayed()

		.setLeft[From](_)
		.setRight[From](_)
		.setTop[From](_)
		.setBottom[From](_)
		.setWidth(_)
		.setHeight(_)
		.getWidth(_)
		.getHeight(_)

	
"*/

class SUIButton extends SUIComponent
{
	
	public static var defaultFont : Font;

	public var click   : Void -> Void;
	public var release : Void -> Void;

	public var isEnabled = true;	// Prevents clicking
	public var hasText = false;
	public var text : String;
	public var font : Font;
	public var textWidth : Float;
	public var textHeight : Float;
	
	public function new(actorTypeName : String, layer : String, ?anim : String){
		super(actorTypeName, layer, anim);
		if(defaultFont != null) font = defaultFont;
		onClick(function(){
			if(isEnabled && isShown && click != null)
				click();
		}, actor);
		onRelease(function(){
			if(isEnabled && isShown && release != null)
				release();
		}, actor);
	}
	
	override public function setAnimation(animationName) {
		actor.setAnimation(animationName);
	}

	public function setText(t, ?f){
		if (f != null) font = f;
		text = t;
		textWidth = font.getTextWidth(text) / Engine.SCALE;
		textHeight = font.getHeight() / Engine.SCALE;
		if(!hasText){
			onDraw(drawText);
			hasText = true;
		}
	}

	function drawText(g : G){
		if(isShown){
			var textX = actor.getXCenter() - textWidth / 2;
			var textY = actor.getYCenter() - textHeight / 2;
			g.setFont(font);
			g.drawString(text, textX, textY);
		}
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

	public override function hide(){
		if(isShown){
			isShown = false;
			actor.disableActorDrawing();
			disable();
		}
	}
	public override function show(){
		if(!isShown){
			isShown = true;
			actor.enableActorDrawing();
			enable();
		}
	}
	

}



























