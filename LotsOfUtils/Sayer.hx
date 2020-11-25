
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
	Sayer is functionality for making chat bubbles appear on the screen (up to 3 chat bubbles at the same time)/

	Note: Must be initialized once per game!
		Sayer.init(actorTypeName)

	Requires:
		- An actor with dimensions 100x70 by default. You can change these
		- a layer called Say


*/

class Sayer
{

	public static var chatBubbleActorType : ActorType;
	public static var font : Font;

	public static inline var chatBubbleWidth = 90;
	public static inline var chatBubbleHeight = 50;
	public static inline var paddingLeft = 2;
	public static inline var paddingTop = 4;
	public static inline var originYOffset = 50;
	public static inline var originXOffset = chatBubbleWidth / 2;
	
	
	public static var textBoxes : Array<TextBox>;
	public static var currentTextBox : Int = 0;
	
	public static function init(chatBubbleActorTypeName : String, f : Font){
		chatBubbleActorType = getActorTypeByName(chatBubbleActorTypeName);
		font = f;
		textBoxes = [null, null, null];
	}

	public static function reset() {
		textBoxes = [null, null, null];
		currentTextBox = 0;
	}
	
	private static function sayAt(s : String, x : Float, y : Float){
		if (chatBubbleActorType == null) {
			trace("ERROR: Sayer not initialized!");
			return -1;
		}
		currentTextBox++;
		trace('  currentTextBox = ${currentTextBox}');
		if (currentTextBox == textBoxes.length) currentTextBox = 0;
		if (textBoxes[currentTextBox] == null) {
			textBoxes[currentTextBox] = new TextBox(chatBubbleWidth - paddingLeft, chatBubbleHeight, 0, 0, font);
			textBoxes[currentTextBox].lineSpacing = 10;
			//textBoxes[currentTextBox].centerVertically = true;
			textBoxes[currentTextBox].centerHorizontally = true;
		}
		var textX = x - originXOffset + paddingLeft;
		textX = x;
		textBoxes[currentTextBox].setPosition(textX, y - originYOffset + paddingTop);
		textBoxes[currentTextBox].reset();
		textBoxes[currentTextBox].setText(s);
		textBoxes[currentTextBox].startDrawing();
		return currentTextBox;
	}
	
	public static function say(s : String, x : Float, y : Float, duration : Float){
		trace('Sayer.say...');
		var cb = createChatBubbleActor(x, y);
		trace('Created bubble. SayingAt(${s}, ${x}, ${y})');
		var thisTextBox = sayAt(s, x, y);
		trace('sayAt(${s}, ${x}, ${y})');
		if (duration > 0) {
			runLater(1000 * duration, function(timeTask:TimedTask):Void {
				remove(new SayerReturnObject(cb, thisTextBox));
			}, null);
			return null;
		} else if (duration == -1) {
			trace('Aight duration -1');
			return new SayerReturnObject(cb, thisTextBox);
		} else {
			trace('Invalid duration given to say: ${duration}');
			return null;
		}
		
	}

	public static function remove(actorTextBoxPair : SayerReturnObject) {
		if (textBoxes[actorTextBoxPair.textBoxIndex] != null) {			// When jumping scenes
			textBoxes[actorTextBoxPair.textBoxIndex].stopDrawing();
		}
		actorTextBoxPair.actor.growTo(0.7, 0.7, 0.05, Easing.linear);
		runLater(50, function(timeTask:TimedTask):Void{
			recycleActor(actorTextBoxPair.actor);
		}, null);
	}
	
	static function createChatBubbleActor(x : Float, y : Float){
		var cb = U.createActor(chatBubbleActorType, "Say");
		cb.setX(x - originXOffset);
		cb.setY(y - originYOffset + 5);
		cb.moveBy(0, -5, 0.03, Easing.linear);
		cb.growTo(0.7, 0.7, 0, Easing.linear);
		cb.growTo(1, 1, 0.03, Easing.linear);
		return cb;
	}

	
	
	
	
	
}