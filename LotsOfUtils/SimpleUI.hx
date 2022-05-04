


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
	
	How to use:
		- Make another class that extends SimpleUI and overrides open, close and load
		- Just call		new SimpleUIExtension() (once per game)
			It is automatically added to the manager
		- To open, use SimpleUIManager.open(name)
			See its API for more details
	
"*/


class SimpleUI
{
	public var name : String = "NOT SET";
	
	public function open(?metaData : Array<Dynamic>){}		// When the UI is opened, with a parameter, do what you want with it
	public function openWith(?options: Dynamic){}			// When the UI is opened with openWith, open with parameters
	public function close(){}						// When the UI is closed
	public function load(){}						// When the UI loads into the scene for the first time
	
	//public static var self = this;			// Use this in subclasses
	
	public function new(n : String){
		name = n;
		GUI.add(this);
	}
	
}



























