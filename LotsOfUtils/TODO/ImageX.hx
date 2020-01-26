
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


/*
	API:

*/


class ImageX
{
	
	public var image : BitmapWrapper;
	public var isAttachedToScreen = true;
	public var layerName : String = "!NONE";
	public var isAlive = true;
	public var isShown = true;
	
	public function new(?path : String, ?bitmapData : BitmapData, ?layerName : String){
		if(path != null){
			image = new BitmapWrapper(new Bitmap(getExternalImage(path)));
		} else if(bitmapData != null){
			image = new BitmapWrapper(new Bitmap(bitmapData));
		}
		if(image == null) trace("ERROR: ImageX could not be loaded");
		if(layerName != null){
			isAttachedToScreen = false;
			this.layerName = layerName;
			attachImageToLayer(image, 1, layerName, 0, 0, 1);
		} else {
			isAttachedToScreen = true;
			attachImageToHUD(image, 0, 0);
		}
		image.scaleX = image.scaleX * Engine.SCALE;
		image.scaleY = image.scaleY * Engine.SCALE;
	}
	
	public function changeImage(path : String){
		var oldX = getX();
		var oldY = getY();
		removeImage(image);
		image = new BitmapWrapper(new Bitmap(getExternalImage(path)));
		attachImageToLayer(image, 1, layerName, 3, 4, 1);
		image.scaleX = image.scaleX * Engine.SCALE;
		image.scaleY = image.scaleY * Engine.SCALE;
		setX(oldX);
		setY(oldY);
	}
	
	public function show(){
		var oldX = getX();
		var oldY = getY();
		if(!isAlive || isShown) return;
		if(isAttachedToScreen) attachImageToHUD(image, 0, 0);
		else attachImageToLayer(image, 1, layerName, 3, 4, 1);
		setX(oldX);
		setY(oldY);
		isShown = true;
	}
	
	public function hide(){
		if(!isAlive || !isShown) return;
		removeImage(image);
		isShown = false;
	}
	
	public inline function getX(){
		return image.x / Engine.SCALE;
	}
	
	public inline function getY(){
		return image.y / Engine.SCALE;
	}
	
	public inline function setX(x : Float){
		image.x = x * Engine.SCALE;
	}
	
	public inline function setY(y : Float){
		image.y = y * Engine.SCALE;
	}
	
	public inline function addX(x : Float){
		setX(getX() + x);
	}
	
	public inline function addY(y : Float){
		setY(getY() + y);
	}
	
	public inline function setXY(x : Float, y : Float){
		setX(x);
		setY(y);
	}
	
	public inline function getWidth(){
		return image.width / Engine.SCALE;
	}
	
	public inline function getHeight(){
		return image.height / Engine.SCALE;
	}
	
	public inline function kill(){
		removeImage(image);
		image = null;
		isAlive = false;
	}
	
	public inline function centerOnScreen(){
		setX(getScreenX() + (getScreenWidth() - getWidth()) / 2);
		setY(getScreenY() + (getScreenHeight() - getHeight()) / 2);
	}
	
	public inline function slide(x : Float, y : Float, time : Int){
		UserInterface.slideImage(this, x, y, time);
	}
	
	public function anchorToScreen(){
		attachImageToHUD(image, Std.int(getX()), Std.int(getY()));
	}
}

















