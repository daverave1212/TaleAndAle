
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



class Frame
{
	
	public var name		: String = "None";
	public var buttons	: Array<Button>;
	public var images	: Array<ImageX>;
	public var actors	: Array<Actor>;
	
	
	public function new(n : String){
		name		= n;
		buttons		= new Array<Button>();
		images		= new Array<ImageX>();
		actors		= new Array<Actor>();
	}
	
	public function add(?b : Button, ?i : ImageX, ?a : Actor){
		if(b != null){
			buttons.push(b);
		}
		if(i != null){
			images.push(i);
			i.anchorToScreen();
		}
		if(a != null){
			actors.push(a);
			a.anchorToScreen();
		}
	}
	
	// Methods to be overridden
	public var onOpen	: Void -> Void;
	public var onClose	: Void -> Void;
	
	// Private - do not edit this!
	public function open(){
		if(onOpen != null) onOpen();
		for(i in 0...buttons.length){
			buttons[i].show();
		}
		for(i in 0...images.length){
			images[i].show();
		}
		for(i in 0...actors.length){
			actors[i].enableActorDrawing();
		}
	}
	
	// Private - do not edit this!
	public function close(){
		if(onClose != null) onClose();
		for(i in 0...buttons.length){
			buttons[i].hide();
		}
		for(i in 0...images.length){
			images[i].hide();
		}
		for(i in 0...actors.length){
			actors[i].disableActorDrawing();
		}
	}
	
	
	
	
}















