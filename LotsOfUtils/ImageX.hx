

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

	--- REQUIRES: U.hx
	
	API:

"*/

// A wrapper for ImageX which can hold some data, like speed and age
// Required for sliding images in ImageX slider part
class ImageXExtended{
	public var image  : ImageX;
	public var xSpeed : Float = 0;
	public var ySpeed : Float = 0;
	public var age	  : Int = 0;		// In miliseconds
	public var maxAge : Int = 0;		// In miliseconds
	
	public function new(img : ImageX){
		image = img;
	}
	
}

class ImageXSlider{

	public static var imagesBeingSlid : Array<ImageXExtended>;
	public static inline var Slide_Frequency = 20;
	
	// This is automatically done by U.changeScene
	public static function start(){
		imagesBeingSlid = [];
		U.repeat(moveImages, Slide_Frequency);
	}
	
	// Helper function called by every tick(..)
	private static function moveImages(){
		for(i in 0...imagesBeingSlid.length){
			var img = imagesBeingSlid[i];
			if(img == null)
				continue;
			img.image.addX(img.xSpeed);
			img.image.addY(img.ySpeed);
			img.age += Slide_Frequency;
			if(img.age >= img.maxAge){
				imagesBeingSlid[i] = null;
			}
		}
	}
	
	public static function slideImage(image : ImageX, destinationX : Float, destinationY : Float, overTime : Int){
		var deltaX = destinationX - image.getX();
		var deltaY = destinationY - image.getY();
		var nTicks = overTime/Slide_Frequency;
		var img = new ImageXExtended(image);
		img.xSpeed = deltaX/nTicks;
		img.ySpeed = deltaY/nTicks;
		img.maxAge = overTime;
		var pos = U.getFirstNull(imagesBeingSlid);
		if(pos == -1){
			imagesBeingSlid.push(img);
		} else {
			imagesBeingSlid[pos] = img;
		}
	}
	
}

class ImageX
{

	// Called automatically by U.changeScene
	public static function _startSlidingImages(){
		ImageXSlider.start();
	}
	
	public var image : BitmapWrapper;
	public var isAttachedToScreen = true;
	public var layerName : String = "!NONE";
	public var isAlive = true;
	public var isShown = true;
	private var originalWidth  : Float = 0;
	private var originalHeight : Float = 0;
	
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
		originalHeight = getHeight();
		originalWidth  = getWidth();
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
	
	public function setWidth(w : Float){	// In pixels
		var perc = w / originalWidth;
		var currentHeightPerc = getHeight() / originalHeight;
		growImageTo(image, perc, currentHeightPerc, 0, Linear.easeNone);
	}
	
	public function setHeight(h : Float){	// In pixels
		var perc = h / originalHeight;
		var currentWidthPerc = getWidth() / originalWidth;
		growImageTo(image, currentWidthPerc, perc, 0, Linear.easeNone);
	}
	
	public inline function resetWidth(){
		setWidth(originalWidth);
	}
	
	public inline function resetHeight(){
		setHeight(originalHeight);
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
	
	public function anchorToScreen(){
		attachImageToHUD(image, Std.int(getX()), Std.int(getY()));
	}
}

















