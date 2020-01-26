


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
	
	--- ALL UI CLASSES REQUIRE: U.hx, Style.hx, eachother
	
	So, this is how the ui will be done:
	1. Create the hierarchy of components, with their own data and stuff
	2. root.refresh() draws the whole view again

"*/

class UIImage extends UIComponent
{
	
	public var image : ImageX;
	public var src = "";
	public var layerName = "~";

	public function new(n, s, ?layerName : String, ?stl : String){
		super(n, stl);
		src = s;
		inheritsWidth = false;
		inheritsHeight = false;
		image = new ImageX(src, layerName);
	}
	
	public override function hide(){
		if(isShown){
			isShown = false;
			image.hide();
		}
	}
	public override function show(){
		if(!isShown){
			isShown = true;
			image.show();
		}
	}
	
	public override function setWidth(w){
		width = w;
		inheritsWidth = false;
		image.setWidth(w);
	}
	
	public override function setHeight(h){
		height = h;
		inheritsHeight = false;
		image.setHeight(h);
	}
	
	public override function getWidth(){
		return image.getWidth();
	}
	
	public override function getHeight(){
		return image.getHeight();
	}

	public override function draw(?frame){
		setupCoordinates(frame);
		if(image != null){
			image.setX(x);
			image.setY(y);
		}
	}
	
	
}



























