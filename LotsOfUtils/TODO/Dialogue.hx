

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

using scripts.Other;

class Dialogue
{
	
	public static var constants = {
		buttonYOffset	: 10,
	}
	
	public static var button1 : Button;
	public static var button2 : Button;
	public static var backgroundBitmap : BitmapData;
	public static var background : ImageX;
	public static var button1Action : Void -> Void;
	public static var button2Action : Void -> Void;
	public static var textBox		: TextBoxPlayable;
	public static var button1Text	: TextBox;
	public static var button2Text	: TextBox;
	
	// Once per scene
	public static function init(){
		trace("Initializing dialogue");
		button1 = new Button(ActorTypes.dialogueChoiceButton(), "Dialogue");
		button2 = new Button(ActorTypes.dialogueChoiceButton(), "Dialogue");
		backgroundBitmap = getExternalImage("ui/DialogueBackground.png");
		var textBoxSize = Other.getBitmapDataSize(backgroundBitmap);	// x = width, y = height
		textBox		= new TextBoxPlayable(textBoxSize.x - 20, textBoxSize.y, 0, 0, FontTypes.dialogueFont());
		button1Text = new TextBox(button1.actor.getWidth().toInt(), button1.actor.getHeight().toInt(), 0, 0, FontTypes.dialogueFont());
		button2Text = new TextBox(button2.actor.getWidth().toInt(), button2.actor.getHeight().toInt(), 0, 0, FontTypes.dialogueFont());
		button1.hide();
		button2.hide();
		button1.addOnClickListener(function(){
			if(button1Action == null){
				Dialogue.close();
				return;
			}
			button1Action();
		});
		button2.addOnClickListener(function(){
			if(button2Action == null){
				Dialogue.close();
				return;
			}
			button2Action();
		});
	}
	
	public static function prompt(
		npc				: NPCData,
		displayText		: String,
		choice1Text		: String,
		choice2Text		: String,
		choice1Action	: Void -> Void,
		choice2Action	: Void -> Void
	){
		trace("Prompting");
		background = new ImageX(backgroundBitmap, "Dialogue");
		button1.show();
		button2.show();
		background.centerOnScreen();
		background.setX(background.getX() - 20);
		trace("Like a quarter through");
		button1.actor.setX(background.getX());
		button2.actor.setX(background.getX() + background.getWidth() - button2.actor.getWidth());
		button1.actor.setY(background.getY() + background.getHeight() + constants.buttonYOffset);
		button2.actor.setY(background.getY() + background.getHeight() + constants.buttonYOffset);
		button1Action = choice1Action;
		button2Action = choice2Action;
		trace("Like half way through");
		textBox.setText(displayText);
		trace("Set text...");
		textBox.setPosition(background.getX() + 10, background.getY() + 10);
		trace("Set pos");
		textBox.startDrawing();
		trace("Started drawing");
		textBox.play();
		trace("Played");
		button1Text.setText(choice1Text);
		trace("Almost there...");
		button2Text.setText(choice2Text);
		button1Text.setPosition(button1.actor.getX() + 3, button1.actor.getY() + 3);
		button2Text.setPosition(button2.actor.getX() + 3, button1.actor.getY() + 3);
		button1Text.startDrawing();
		button2Text.startDrawing();
		trace("Propmted I guess...");
	}
	
	public static function close(){
		background.kill();
		button1.hide();
		button2.hide();
		textBox.stopDrawing();
		button1Text.stopDrawing();
		button2Text.stopDrawing();
	}

	
	/// DEBUG
	public static function _Prompt(){
		var bs = new NPCData("Blackboy", "The Smith", "Blacksmith");
		prompt(bs, "What do you say friend? Friend, or foe? Answer now!",
			   "Friend.", "Foe!",
			function(){
				Dialogue.close();
			},
			function(){
				Dialogue.close();
				Dialogue.prompt(bs, "AHA! So you are foe indeed! Then face by wrath!", "Oh shit!", "Fuck! this man", null, null);
			}
		);
	}
	
	
	

}

















