
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
	var hp : ResourceBar = new ResourceBar(theActor, maximumValue, scalesLeft : Bool, simple : Bool);
		Ex: if scalesLeft is true, then the bar will move to the left, and keep its position on the right
		Ex: if simple is true, then the bar will not animate and it will instantly change
	reset(?newMaxHealth)
	destruct()  // Prevents memory leaks if you constantly create new ones (I hope)
  
*/

class ResourceBar
{
	var actor : Actor;
	var currentPercent : Float = 100;
	public var currentValue : Float = 0;
	var initialActorWidth : Float = 100;
	var maxValue : Float = 0;
	private var destinationValue : Float = 0;
	private var onePercentOfMax : Float = 0;
	private var isIncreasing = false;
	private var isDecreasing = false;
	private var initialX : Float = 0;
	private var initialY : Float = 0;
	public var isScalingLeft = false;
	public var isSimple = false; 
	private var isDestructing = false;
	
	private var shakeDeltaX : Float = 0;
	private var shakeDeltaY : Float = 0;
	

	public function destruct(){
		isDestructing = true;
	}

	public function new(a : Actor, max : Float, ?scalesLeft : Bool, ?simple : Bool){
		actor = a;
		maxValue = max;
		currentValue = max;
		destinationValue = max;
		onePercentOfMax = max / 100;
		initialX = a.getX();
		initialY = a.getY();
		initialActorWidth = a.getWidth();
		if(scalesLeft != null){
			isScalingLeft = scalesLeft;
		}
		if(simple != null){
			isSimple = simple;
		}
		runPeriodically(20, function(timeTask:TimedTask):Void{
			if(isDestructing){
				return;}
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
		actor.setX(initialX);
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
		var currentWidth = currentPercent * initialActorWidth / 100;
		//var currentDeltaWidth = initialActorWidth - currentWidth;
		var newPercent = value * 100 / maxValue;
		var newWidth = newPercent * initialActorWidth / 100;
		var newDeltaWidth = currentWidth - newWidth;
		actor.growTo(newPercent/100, 1, 0, Linear.easeNone);
		if(isScalingLeft){
			actor.setX(actor.getX() + newDeltaWidth/2 + shakeDeltaX);
		} else {
			actor.setX(actor.getX() - newDeltaWidth/2 + shakeDeltaX);
		}
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
