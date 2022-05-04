
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

import com.stencyl.utils.motion.*;

/*
	How to use:
	1. Create a FloatingTextManager object (var f = nwe FloatingTextManager(theFont, ?extraBounciness : Float)
			extraBounciness is a number between 0 and 1, 1 meaning 100% bonus and 0 0% bonus bounciness
	2. Use the .pump("text", x, y, ?right : Bool) function!
			if right is true, the text will jump right, else, left
	
	TODO: Customize it so it is customizable on X and Y axis both!
*/


class _Text {
	public var x : Float;
	public var y : Float;
	public var text : String = "";
	public var gravityY : Float = 0;
	public var gravityX : Float = 0;
	public var isAlive : Bool = true;
	
	public function new(t : String, _x : Float, _y : Float, gy : Float, gx : Float, ?alive : Bool){
		text = t;
		x = _x;
		y = _y;
		gravityX = gx;
		gravityY = gy;
		if(alive != null){
			isAlive = alive;
		}
	}
	
	public inline function draw(g : G){
		g.drawString(text, x, y);
	}
	
	public inline function updatePositionsAndGravity(gravityIncrementY : Float, ?gravityIncrementX : Float){
		x += gravityX;
		y += gravityY;
		gravityY += gravityIncrementY;
		if(gravityIncrementX != null){
			gravityX += gravityIncrementX;
		}
	}
}

class FloatingTextManager extends SceneScript
{
	
	public var texts : Array<_Text>;
	
	var screenHeight : Float;
	var gravityIncrementY : Float = 0.1;
	var gravityDefaultY : Float = -4;
	var gravityDefaultX : Float = -2;
	private var font : Font = null;
	
	public function new(f : Font, ?bouncinessIncrement : Float) {
		super();
		font = f;
		texts = new Array<_Text>();
		if (bouncinessIncrement != null) {
			gravityIncrementY = gravityIncrementY * (bouncinessIncrement + 1);
			gravityDefaultY = gravityDefaultY * (bouncinessIncrement + 1);
			gravityDefaultX = gravityDefaultX * (bouncinessIncrement/2 + 1);
		}
		screenHeight = getScreenHeight();
		runPeriodically(5, function(timeTask:TimedTask):Void{
			updateGravities();
		}, null);
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void {
			drawTexts(g);
		});
	}
	
	public function pump(?nr: Float, ?s : String, x : Float, y : Float, ?right : Bool = false) {
		var txt : String = "";
		if (nr != null) {
			if (nr - Math.floor(nr) == 0) {
				txt = "" + Std.int(nr);
			} else {
				txt = "" + nr;
			}
		} else {
			if (s != null) {
				txt = s;
			}
		}
		final gravityXModifier = if (right) -1 else 1;
		final t: _Text = new _Text(txt, x, y, gravityDefaultY, gravityXModifier * gravityDefaultX);
		addText(t);
	}
	
	private function addText(t : _Text){
		for (i in 0...texts.length) {
			if (texts[i] != null) {
				if (texts[i].isAlive == false) {
					texts[i] = t;
					return;
				}
			}
		}
		texts.push(t);
	}
	
	private function updateGravities(){
		for (i in 0...texts.length) {
			if (texts[i].isAlive == false) continue;
			texts[i].updatePositionsAndGravity(gravityIncrementY);
			if (texts[i].y > screenHeight) {
				texts[i].isAlive = false;
			}
		}
	}
	
	private function drawTexts(g : G) {
		g.setFont(font);
		for (i in 0...texts.length) {
			texts[i].draw(g);
		}
	}
	
}
