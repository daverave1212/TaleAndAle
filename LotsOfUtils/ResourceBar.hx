
import com.stencyl.graphics.G;

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
import com.stencyl.utils.Utils;

import nme.ui.Mouse;
import nme.display.Graphics;

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

/*
	How to use:
	var hp : ResourceBar = new ResourceBar("BarActorTypeName", "TheLayer", maxValue, leftToRight : Bool, simple : Bool)
		Ex: if simple is true, then the bar will not animate and it will instantly change
	reset(?newMaxHealth)
	destruct()  // Prevents memory leaks if you constantly create new ones (I hope)
  
*/


import U.*;
using U;

class ResourceBar
{
	var actor : Actor;
	var currentPercent : Float = 100;
	public var currentValue : Float = 0;
	var initialWidth : Float = 100;
	var maxValue : Float = 0;
	var destinationValue : Float = 0;
	var onePercentOfMax : Float = 0;
	var isIncreasing = false;
	var isDecreasing = false;
	var initialX : Float = 0;
	public var isLeftToRight = true;
	public var isSimple = false; 
	public var isSmall = false;		// If its width is less than 100px 
	var isDestructing = false;

	var shakeDeltaX : Float = 0;
	var shakeDeltaY : Float = 0;
	

	public function destruct(){
		isDestructing = true;
	}

	public function setX(x : Float){
		initialX = x;
		var currentWidth = currentPercent * initialWidth / 100;
		var deltaWidth = initialWidth - currentWidth;
		actor.setX(initialX - deltaWidth/2);
	}

	public function setXCenter(x : Float){
		var realX = x - initialWidth/2;
		setX(realX);
	}
	public inline function setYCenter(y : Float) actor.setYCenter(y);
	public inline function setY(y : Float) actor.setY(y);
	public inline function show() actor.enableActorDrawing();
	public inline function hide() actor.disableActorDrawing();


	public function new(actorName : String, layerName : String, max : Float, ?l2r : Bool = true, ?simple : Bool = false){
		actor = createActor(actorName, layerName);
		maxValue = max;
		currentValue = max;
		destinationValue = max;
		onePercentOfMax = max / 100;
		initialWidth = actor.getWidth();
		isLeftToRight = l2r;
		isSimple = simple;
		if(actor.getWidth() < 100)
			isSmall = true;
		runPeriodically(20, function(timeTask:TimedTask):Void{
			if(isDestructing)
				return;
			updateHealthBar();
		}, null);
	}
	
	public function add(value : Float){
		if(isSimple){
			scaleTo(currentValue + value);
		} else {
			if(value < 0){
				isDecreasing = true;
				isIncreasing = false;
			} else {
				isIncreasing = true;
				isDecreasing = false;
			}
			destinationValue = destinationValue + value;
		}
	}
	
	public function set(value : Float){
		if(isSimple){
			scaleTo(value);
			return;
		}
		if(value > destinationValue){
			isIncreasing = true;
			isDecreasing = false;
		} else {
			isIncreasing = false;
			isDecreasing = true;
		}
		destinationValue = value;
	}
	
	public function reset(?m : Float){
		if(m != null){
			maxValue = m;
		}
		actor.growTo(1, 1, 0, Linear.easeNone);
		isIncreasing = false;
		isDecreasing = false;
		currentPercent = 100;
		currentValue = maxValue;
		destinationValue = maxValue;
		onePercentOfMax = maxValue / 100;
	}
	
	public function shake(?amount : Float){
		// TO DO
	}
	
	private function scaleTo(value : Float){
		var newPercent = value.whatPercentOf(maxValue);
		var newWidth = initialWidth * (newPercent / 100);
		actor.growTo(newPercent/100, 1, 0, Linear.easeNone);
		var deltaWidth = initialWidth - newWidth;
		if(isLeftToRight){
			actor.setX(initialX - deltaWidth/2);
		}
		else
			trace("Sry mate");
		currentPercent = newPercent;
		currentValue = value;
	}
	
	private function updateHealthBar(){
		if(isSimple) return;
		if(currentValue > destinationValue + onePercentOfMax){
			scaleTo(currentValue);
			currentValue -= onePercentOfMax;
		} else if(currentValue < destinationValue - onePercentOfMax){
			scaleTo(currentValue);
			currentValue += onePercentOfMax;
		}
		return;
	}
	
	
}
