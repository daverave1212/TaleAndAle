
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
import Math.abs;
import Math.max;
import Math.pow;
import Std.int;

/*
	Use:
		sendMissileAndThen(from:Point, to:Point, missileName:String, speed: SLOW|MEDIUM|FAST, doThis)
		playParticleAndThen(from:Point, to:Point, effectName:String, durationInMiliseconds, doThis)

*/

class Effects
{
	// Effect speeds
	public static var SLOW	 	 = 100;		// px/s
	public static var MEDIUM	 = 250;		// px/s
	public static var FAST	 	 = 500;		// px/s
	
	// Y-Offset
	public static inline var defaultYOffset = 35;


	/*
		(from - to) is positive = to go up = must decrease
		(from - to) is negative = to go down = must increase
	*/

	public static function sendArcMissileCustomAndThen(options: {
		from: Point, to: Point,
		actorName: String,
		missileName: String,
		speed: Float,
		andThen: Void -> Void,
		?onActorCreated: Actor -> Void
	}): Float {	// Returns the total time of the missile
		var from = options.from, to = options.to, actorName = options.actorName, missileName = options.missileName, speed = options.speed;
		
		if (speed == MEDIUM)
			speed = int(0.66 * MEDIUM);
		if (speed == FAST)
			speed = MEDIUM;
		var missile = createActor(actorName, "Particles");
		missile.setAnimation(missileName);
		missile.setX(from.x);
		missile.setY(from.y);
		if (options.onActorCreated != null)
			options.onActorCreated(missile);
		var distanceX = int(Math.max(abs(from.x - to.x), 150));
		var time = int(1000 * distanceX / speed);
		var missileHeight = 125;
		slideActorX(missile, from.x, to.x, time);
		slideActorYCubic(missile, from.y, (from.y + to.y) / 2 - missileHeight, int(time / 2));		
		doAfter(int(time / 2), () -> {
			slideActorYCubic(missile, (from.y + to.y) / 2 - missileHeight, to.y, int(time / 2), true);
		});
		doAfter(time, () -> {
			recycleActor(missile);
			if (options.andThen != null)
				options.andThen();
		});
		return time;
	}
	public static function sendArcMissileAndThen(from: Point, to: Point, missileName: String, speed: Float, ?doThis: Void->Void = null) {
		return sendArcMissileCustomAndThen({ from: from, to: to, actorName: 'MissileActor', missileName: missileName, speed: speed, andThen: doThis });
	}
	
	public static function sendMissileAndThen(from : Point, to : Point, missileName : String, speed : Float, doThis : Void->Void, ?options: {
		?easingName: String
	}): Float {
		if (options == null) 
			options = {};
		var missile = createActor("MissileActor", "Particles");
		missile.setAnimation(missileName);
		missile.setX(from.x);
		missile.setY(from.y);
		var deltaX = from.x - to.x;
		var deltaY = from.y - to.y;
		final isMoreHorizontal = abs(deltaX) > abs(deltaY);
		missile.setActorValue('isFlipped', false);			// Maybe used in SpecialEffectsFluff
		if(isMoreHorizontal) {	    						// Point the missile 'towards' the target
			if (from.x < to.x)								// I know, it can be refactored to work
				missile.setAngle(Utils.RAD * 0);			//  with rounding by 90 or something
			else if(to.x < from.x) {
				missile.growTo(-1, 1, 0, Easing.linear);
				missile.setActorValue('isFlipped', true);
			}
		} else if(abs(deltaX) < abs(deltaY)){
			if(deltaY < 0)
				missile.setAngle(Utils.RAD * 90);
			else if(deltaY > 0)
				missile.setAngle(Utils.RAD * -90);
		} else {
			if (deltaX > 0)
				missile.setAngle(Utils.RAD * 180);
		}
		final maxDistance = max(abs(deltaX), abs(deltaY));	// 60 - 360 px
		final time =  maxDistance / speed;
		final easingType: String = if (options.easingName == null) 'quadIn' else options.easingName;
		final easing =
			if (easingType == 'quadIn') Easing.quadIn
			else Easing.linear;
		missile.moveTo(to.x, to.y, time, easing);
		doAfter(Std.int(1000 * time), function(){
			// trace('  Ended missile journey at ${missile.getX()}, ${missile.getY()}');
			recycleActor(missile);
			if(doThis != null) doThis();
		});
		return time;
	}
	
	/*
		This uses an ActorType (SpecialEffectActor) which it spawns and plays that specific animation once.
		The actual particles with ParticleSpawner are coded inside the SpecialEffectActor.
	*/
	public static function playParticleAndThen(from : Point, at : Point, effectName : String, durationInMiliseconds : Int, ?doThis : Void->Void): Actor {
		// trace('Playing effect named "${effectName}"');
		return playParticleCustomActorAndThen(from, at, "SpecialEffectActor", effectName, durationInMiliseconds, doThis);
	}
	public static function playParticleCustomActorAndThen(from : Point, at : Point, actorTypeName : String, effectName : String, durationInMiliseconds, ?doThis : Void->Void) {
		var flipHorizontally = false;
		var flipVertically = false;
		var direction = 'no-direction';
		// trace('Sure, continuing with effect name = ${effectName}');
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
		var specialEffect = playActorParticle(actorTypeName, effectName, options, () -> { if (doThis != null) doThis(); });
		specialEffect.setActorValue('direction', direction);	// For potential in-actor scripts
		return specialEffect;
	}

	public static function playOnlyParticleAt(x: Float, y: Float, effectName: String) {
		playParticleAndThen(new Point(x, y), new Point(x, y), effectName, 150, () -> {});
	}
	public static function playEffectAt(x: Float, y: Float, effectName: String, duration: Int = 150) {
		playParticleAndThen(new Point(x, y), new Point(x, y), effectName, duration, () -> {});
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


















