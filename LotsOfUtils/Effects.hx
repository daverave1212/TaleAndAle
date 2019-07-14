
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

class Effects
{
	// Effect speeds
	public static inline var SLOW	 = 100;		// px/s
	public static inline var MEDIUM	 = 250;		// px/s
	public static inline var FAST	 = 500;		// px/s
	
	// Y-Offset
	public static inline var defaultYOffset = 35;
	
	public static function sendMissileAndThen(from : Point, to : Point, missileName : String, speed : Float, callback : Void->Void){
		createLayerIfDoesntExist("Particles", 50);
		var missile = createActor("MissileActor", "Particles");
			missile.setX(from.x);
			missile.setY(from.y);
		var deltaX = from.x - to.x;
		var deltaY = from.y - to.y;
		if(Math.abs(deltaX) > Math.abs(deltaY)){			// Point the missile 'towards' the target
			if(deltaX < 0)									// I know, it can be refactored to work
				missile.setAngle(Utils.RAD * 0);			//  with rounding by 90 or something
			else if(deltaX > 0)
				missile.setAngle(Utils.RAD * 180);
		} else if(Math.abs(deltaX) < Math.abs(deltaY)){
			if(deltaY < 0)
				missile.setAngle(Utils.RAD * 90);
			else if(deltaY > 0)
				missile.setAngle(Utils.RAD * -90);
		} else {
			if(deltaX > 0)
				missile.setAngle(Utils.RAD * 180);
		}
		var maxDistance = Math.max(Math.abs(deltaX), Math.abs(deltaY));	// 60 - 360 px
		var time =  maxDistance / speed;
		missile.moveTo(to.x, to.y, time, Quad.easeIn);
		doAfter(1000 * time, function(){
			recycleActor(missile);
			doThis();
		});
	}
	
	public static function playParticleAndThen(from : Point, at : Point, effectName : String, callback : Void->Void){
		createLayerIfDoesntExist("Particles", 50);
		var specialEffect = createActor("SpecialEffectActor", "Particles", at.x, at.y);
		specialEffect.setAnimation(effectName);
		setXCenter(specialEffect, at.x);
		setYCenter(specialEffect, at.y);
		if(from.x <= at.x){
			if(from.y >= at.y){
				// It's ok
			} else 
				flipActorVertically(specialEffect);
		} else {
			flipActorHorizontally(specialEffect);
			if(from.y >= at.y){
				// It's ok
			} else 
				flipActorVertically(specialEffect);
		}
		doAfter(1000, function(){
			recycleActor(specialEffect);
			callback();
		})
	}

	
}


















