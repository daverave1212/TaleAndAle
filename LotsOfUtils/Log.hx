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

class Log extends SceneScript
{
	public static var theLog : Log;
	public static var nRows : Int = 3;
	public static var rows : Array<String>;
	
	public static function start(?_rows : Int){
		theLog = new Log();
		if(_rows != null) nRows = _rows;
		rows = new Array<String>();
		for(i in 0...nRows){
			rows.push("");
		}
	}
	
	public static function go(s : String){
		for(i in 0...rows.length - 1){
			rows[i] = rows[i+1];
		}
		rows[rows.length - 1] = s;
	}
	
	public function new(){
		super();
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			drawConsole(g);
		});
	}
	
	public function drawConsole(g : G){
		for(i in 0...rows.length){
			g.drawString(rows[i], 10 + getScreenX(), getScreenY() + 10 + i * 20);
		}
	}
	
	
}