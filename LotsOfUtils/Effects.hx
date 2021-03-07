
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

class Effects
{
	// Effect speeds
	public static inline var SLOW	 = 100;		// px/s
	public static inline var MEDIUM	 = 250;		// px/s
	public static inline var FAST	 = 500;		// px/s
	
	// Y-Offset
	public static inline var defaultYOffset = 35;
	
	public static function sendMissileAndThen(from : Point, to : Point, missileName : String, speed : Float, doThis : Void->Void){
		var missile = createActor("MissileActor", "Particles");
		missile.setAnimation(missileName);
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
		missile.moveTo(to.x, to.y, time, Easing.quadIn);
		doAfter(Std.int(1000 * time), function(){
			trace('  Ended missile journey at ${missile.getX()}, ${missile.getY()}');
			recycleActor(missile);
			if(doThis != null) doThis();
		});
	}
	
	/*
		This uses an ActorType (SpecialEffectActor) which it spawns and plays that specific animation once.
		The actual particles with ParticleSpawner are coded inside the SpecialEffectActor.
	*/
	public static function playParticleAndThen(from : Point, at : Point, effectName : String, durationInMiliseconds : Int, doThis : Void->Void){
		playParticleCustomActorAndThen(from, at, "SpecialEffectActor", effectName, durationInMiliseconds, doThis);
	}
	public static function playParticleCustomActorAndThen(from : Point, at : Point, actorTypeName : String, effectName : String, durationInMiliseconds, doThis : Void->Void) {
		var flipHorizontally = false;
		var flipVertically = false;
		var direction = 'no-direction';
		if (from != null) {
			if (from.x <= at.x) {
				if (from.y >= at.y) {
					direction = 'right';
				} else {
					flipVertically = true;
					direction = 'up';
				}
			} else {
				flipHorizontally = true;
				if(from.y >= at.y){
					direction = 'left';
				} else {
					flipVertically = true;
					direction = 'down';
				}
			}
		}
		var options = {
			xCenter: at.x,
			yCenter: at.y,
			flipHorizontally: flipHorizontally,
			flipVertically: flipVertically,
			durationInMiliseconds: durationInMiliseconds
		};
		var specialEffect = playActorParticle(actorTypeName, effectName, options, doThis);
		specialEffect.setActorValue('direction', direction);	// For potential in-actor scripts
	}


	
	public static final _optionsExample = {
		xCenter: 100,
		yCenter: 100,
		flipHorizontally: true,
		flipVertically: true,
		durationInMiliseconds: 500
	}
	public static function playActorParticle(actorTypeName: String, animationName: String, options: Dynamic, ?doThis: Void->Void) {
		createLayerIfDoesntExist("Particles", 50);
		var specialEffect = createActor(actorTypeName, "Particles", 0, 0);
		specialEffect.setAnimation(animationName);
		setXCenter(specialEffect, options.xCenter);
		setYCenter(specialEffect, options.yCenter);
		if (options.flipVertically == true) flipActorVertically(specialEffect);
		if (options.flipHorizontally == true) flipActorHorizontally(specialEffect);
		var duration = if (options.durationInMiliseconds == null) 500 else options.durationInMiliseconds;
		doAfter(duration, () -> {
			recycleActor(specialEffect);
			if (doThis != null) doThis();
		});
		return specialEffect;
	}


	
}


















