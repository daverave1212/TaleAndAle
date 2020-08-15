

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

	--- REQUIRES: U.hx
	
	API:
	new(path/BitmapData, layerName)

	.isShown
	.isAlive
	.changeImage(path)
	.show()
	.hide()
	.getX/Y(_)
	.setX/Y(_)
	.getZ()				Refers to the Z-ordering of the image inside the current layer
	.setZ(_)			Refers to the Z-ordering of the image inside the current layer
	.addX/Y(_)
	.setXY(_, _)
	.getWidth()
	.getHeight()
	.setWidth()
	.setHeight()
	.resetWidth()
	.resetHeight()
	.anchorToScreen()
	.kill()


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
		if(image == null){
			var layerMessage = "";
			if(layerName == null) layerMessage = '(unspecified)';
			else layerMessage = '($layerName)';
			if(path != null){
				throw 'Error loading ImageX "$path" on layer $layerMessage';
			} else {
				throw 'Error loading ImageX from bitmapon layer $layerMessage';
			}
		}
		if(layerName != null){
			isAttachedToScreen = false;
			this.layerName = layerName;
			attachImageToLayer(image, cast engine.getLayerByName(layerName), 0, 0, 1);
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
		attachImageToLayer(image, cast engine.getLayerByName(layerName), 0, 0, 1);
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
		else attachImageToLayer(image, cast engine.getLayerByName(layerName), 0, 0, 1);
		setX(oldX);
		setY(oldY);
		isShown = true;
	}
	
	public function hide(){
		if(!isAlive || !isShown) return;
		removeImage(image);
		isShown = false;
	}
	
	public inline function getX() return image.x / Engine.SCALE;
	public inline function getY() return image.y / Engine.SCALE;
	public inline function getZ() return getOrderForImage(image); 
	public inline function setX(x : Float) image.x = x * Engine.SCALE;
	public inline function setY(y : Float) image.y = y * Engine.SCALE;
	public inline function setZ(z : Int) setOrderForImage(image, z);
	public inline function getWidth() return image.width / Engine.SCALE;
	public inline function getHeight() return image.height / Engine.SCALE;

	public inline function resetWidth() setWidth(originalWidth);
	public inline function resetHeight() setHeight(originalHeight);
	public function setWidth(w : Float){	// In pixels
		var perc = w / originalWidth;
		var currentHeightPerc = getHeight() / originalHeight;
		growImageTo(image, perc, currentHeightPerc, 0, Easing.linear);
	}
	public function setHeight(h : Float){	// In pixels
		var perc = h / originalHeight;
		var currentWidthPerc = getWidth() / originalWidth;
		growImageTo(image, currentWidthPerc, perc, 0, Easing.linear);
	}
	public inline function kill(){
		removeImage(image);
		image = null;
		isAlive = false;
	}
	public function anchorToScreen(){
		attachImageToHUD(image, Std.int(getX()), Std.int(getY()));
	}



	public inline function getXScreen() return getX() / Engine.SCALE - Std.int(getScreenX());
	public inline function getYScreen() return getY() / Engine.SCALE - Std.int(getScreenY());
	public inline function setXScreen(x : Float) setX(getX() + Std.int(getScreenX()));
	public inline function setYScreen(y : Float) setY(getY() + Std.int(getScreenY()));
	public inline function addX(x : Float) setX(getX() + x);
	public inline function addY(y : Float) setY(getY() + y);
	public inline function setXY(x : Float, y : Float){
		setX(x);
		setY(y);
	}
	public inline function setLeft(value : Float){ setX(getScreenX() + value); return this; }
	public inline function setLeftFrom(value : Float, offset : Float){ setX(value + offset); return this; }
	public inline function setRight(value : Float){ setX(getScreenX() + getScreenWidth() - getWidth() - value); return this; }
	public inline function setRightFrom(value : Float, offset : Float){ setX(offset - getWidth() - value); return this; }
	public inline function setTop(value : Float){ setY(getScreenY() + value); return this; }
	public inline function setTopFrom(value : Float, offset : Float){ setY(value + offset); return this; }
	public inline function setBottom(value : Float){ setY(getScreenY() + getScreenHeight() - getHeight() - value); return this; }
	public inline function setBottomFrom(value : Float, offset : Float){ setY(offset - getHeight() - value); return this; }
	public inline function getBottom() return getY() + getHeight();
	public inline function getRight() return getX() + getWidth();
	public inline function getLeft() return getX();
	public inline function getTop() return getY();
	public inline function centerVertically(){ setTop(getScreenHeight() / 2 - getHeight() / 2); return this; }
	public inline function centerHorizontally(){ setLeft(getScreenWidth() / 2 - getWidth() / 2); return this; }
	public inline function centerOnScreen(){
		setX(getScreenX() + (getScreenWidth() - getWidth()) / 2);
		setY(getScreenY() + (getScreenHeight() - getHeight()) / 2);
		return this;
	}
	public inline function bringToFront() {
		bringImagetoFront(image);
		return this;
	}
	public inline function bringToBack() {
		bringImageToBack(image);
		return this;
	}

	public inline function grayOut() {
		setFilterForImage(image, createSaturationFilter(0));
	}


}

















