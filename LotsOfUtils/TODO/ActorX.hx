

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

class ActorX
{
	public var self 		: Actor;
	public var isEnabled	= true;
	public var _onClick		: Void -> Void;
	public var _onRelease	: Void -> Void;
	
	public function addOnClickListener(func : Void -> Void){
		_onClick = func;
		if(UserInterface.ui == null){
			trace("ERROR: UserInterface.ui not initialized.");
			return;
		}
		UserInterface.ui.addMouseOverActorListener(self, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(!isEnabled) return;
			if(3 == mouseState){_onClick();}});
	}
	
	public function enable(){
		isEnabled = true;
	}
	
	public function disable(){
		isEnabled = false;
	}
	
	public function addOnReleaseListener(func : Void -> Void){
		_onRelease = func;
		if(UserInterface.ui == null){
			trace("ERROR: UserInterface.ui not initialized.");
			return;
		}
		UserInterface.ui.addMouseOverActorListener(self, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(!isEnabled) return;
			if(5 == mouseState){_onRelease();}});
	}

	public function new(?actorTypeName : String, ?actorType : ActorType, ?layerName : String, ?layerID : Int){
		var a : Actor;
		if(actorTypeName != null){
			actorType = getActorTypeByName(actorTypeName);
		}
		if(layerName != null){
			a = createRecycledActorOnLayer(actorType, 0, 0, 1, layerName);
		} else if(layerID != null){
			a = createRecycledActorOnLayer(actorType, 0, 0, 0, layerID + "");
		} else {
			return;
		}
		self = a;
	}

}



