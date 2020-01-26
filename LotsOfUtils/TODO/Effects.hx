
package scripts;

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

class Effects
{
	// Effect speeds
	public static inline var SlowSpeed = 2;
	public static inline var MediumSpeed = 5;
	public static inline var FastSpeed = 7;
	
	// Y-Offset
	public static inline var defaultYOffset = 35;
	
	public static function sendMissileAndThen(from : TileSpace, to : TileSpace, missileName : String, speed : Float, doThis : Void -> Void){
		var xOrigin = from.tileActor.getXCenter();
		var yOrigin = from.tileActor.getYCenter() - defaultYOffset;
		var xTarget = to.tileActor.getXCenter();
		var yTarget = to.tileActor.getYCenter() - defaultYOffset;
		var missile = createRecycledActorOnLayer(ActorTypes.missile(), xOrigin, yOrigin, 1, "Particles");
		var deltaX = from.matrixX - to.matrixX;
		var deltaY = from.matrixY - to.matrixY;
		if(Math.abs(deltaX) > Math.abs(deltaY)){			// Point the missile 'towards' the target
			if(deltaX < 0){									// I know, it can be refactored to work
				missile.setAngle(Utils.RAD * (0));			//  with rounding by 90 or something
			}
			else if(deltaX > 0){
				missile.setAngle(Utils.RAD * (180));
			}
		} else if(Math.abs(deltaX) < Math.abs(deltaY)){
			if(deltaY < 0){
				missile.setAngle(Utils.RAD * (90));
			} else if(deltaY > 0){
				missile.setAngle(Utils.RAD * (-90));
			}
		} else{
			if(deltaX > 0){
				missile.setAngle(Utils.RAD * (180));
			}
		}
		var time = Math.max(Math.abs(deltaX), Math.abs(deltaY)) / speed;	// 1-6 / 3 = 0.33-2
		missile.moveTo(xTarget, yTarget, time, Quad.easeIn);
		runLater(1000 * time, function(timeTask:TimedTask):Void{
			recycleActor(missile);
			doThis();
		}, null);
	}
	
	public static function playParticleAndThen(from : TileSpace, to : TileSpace, spellBeingCast : Spell, doThis : Void -> Void){
		var xOrigin = from.tileActor.getXCenter();
		var yOrigin = from.tileActor.getYCenter() - defaultYOffset;
		var xTarget = to.tileActor.getXCenter();
		var yTarget = to.tileActor.getYCenter() - defaultYOffset;
		var specialEffect = createRecycledActorOnLayer(ActorTypes.specialEffect(), xTarget, yTarget, 1, "Particles");
		//createRecycledActorOnLayer(getActorType(23), xTarget, yTarget, 1, "Say");
		//createRecycledActorOnLayer(getActorType(23), to.unitOnIt.actor.getX(), to.unitOnIt.actor.getY(), 1, "Say");
		UI.setXCenter(specialEffect, xTarget);
		UI.setYCenter(specialEffect, yTarget);
		if(xOrigin <= xTarget){
			if(yOrigin >= yTarget){
				// It's ok
			} else {
				Other.flipActorVertically(specialEffect);
			}
		} else {
			Other.flipActorHorizontally(specialEffect);
			if(yOrigin >= yTarget){
				// It's ok
			} else {
				Other.flipActorVertically(specialEffect);
			}
		}
		runLater(1000 * spellBeingCast.getSpecialEffectDuration() , function(timeTask:TimedTask):Void{
			recycleActor(specialEffect);
			doThis();
		}, null);
	}
	
}


















