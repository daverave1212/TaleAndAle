


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

/*"
	
	make("ViewName", function(UIView) : UIComponent)
	load("ViewName")
	show("ViewName")
	hide("ViewName")
	change("ViewName")
	
	
"*/

class UIManager
{
	
	public static var views : Map<String, UIView>;
	public static var currentViews : Array<UIView> = [];
	
	public static function init(){
		views = new Map<String, UIView>();
	}
	
	public static function make(s : String, func : UIView->UIComponent){
		views[s] = new UIView(s, func);
	}
	
	public static function load(s : String){
		if(views[s] == null){
			trace('ERROR: No view $s');
			return;
		}
		views[s].load();
		views[s].root.draw();
		views[s].hide();
	}
	
	public static function change(s : String){
		for(v in currentViews){
			v.hide();
		}
		currentViews = [];
		show(s);
	}
	
	public static function show(s : String){
		if(views[s] == null){
			trace('ERROR: No view $s');
			return;
		}
		var view = views[s];
		currentViews.push(view);
		view.show();
		views[s].root.draw();
	}
	
	public static function hide(s : String){
		if(views[s] == null){
			trace('ERROR: No view $s');
			return;
		}
		var view = views[s];
		view.hide();
		if(currentViews.indexOf(view) != -1){
			currentViews.remove(view);
		}
	}
	
	public static function get(viewName : String){
		return views[viewName];
	}
	
}

