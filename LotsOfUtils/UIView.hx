


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

class UIView
{
	public var name : String;
	private var loadFunction : UIView->UIComponent;
	public var root : UIComponent;
	
	public function new(n : String, _loadFunction : UIView->UIComponent){
		name = n;
		loadFunction = _loadFunction;
	}
	
	public function load(){
		if(loadFunction != null){
			root = loadFunction(this);
		} else {
			trace("ERROR: UIView " + name + " has no loadFunction.");
		}
	}
	
	public function show(){
		root.show();
	}
	
	public function hide(){
		root.hide();
	}
	
	public function get(elementName : String){
		return root.get(elementName);
	}
	
}



























