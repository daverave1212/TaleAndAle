
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


/*
	API: (does not require initialization)
		Log.toggle()
		Log.openConsole()
		Log.closeConsole()
		Log.go(message)		// Just prints it to the console

		Log.runCommand(string)	// Runs a command

		Log.setFont(f)

		Set the commands like this:
			Log.commands = [
				'trace' => function(args){
					trace(args[0]);
				}
			];



*/



enum SplitState {
    READING_SPACES;
    READING_QUOTE;
    READING_PARAM;
}

class Log extends SceneScript
{
	public static var theLog : Log;
	public static var nRows : Int = 4;
	public static var rows : Array<String>;
	public static var font : Font = null;
	public static var isOpen = false;
	public static var currentInput : String = '';

	public static var history : Array<String> = [];

	public static var isInitialized = false;	// Automatically called by U. Don't mess with this.

	public static var commands : Map<String, (Array<String> -> String)>;

	public static function setFont(f){
		font = f;
	}

	public static function openConsole(){
		if(!isInitialized){
			initialize();
		}
		isOpen = true;
	}

	public static function toggle(){
		if(isOpen){
			closeConsole();
		} else {
			openConsole();
		}
	}

	public static function initialize(){
		theLog = new Log();
		isInitialized = true;
		rows = [for (_ in 0...nRows) ''];
		currentInput = '';
		isOpen = false;
	}

	public static function closeConsole(){
		isOpen = false;
	}
	
	public static function go(s : String){
		rows.shift();
		rows.push(s);
		history.push(s);
		return s;
	}
	
	public function new(){
		super();
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			drawConsole(g);
		});
		U.onKeyPress(function(charCode){
			if(charFromCharCode(charCode) == '`'){
				//Log.toggle();
			} else if(charCode == 13){	// ENTER
				Log.enter();
			} else if(charCode == 8){	// BACKSPACE
				Log.backspace();
			} else if(charFromCharCode(charCode) != ''){
				currentInput += charFromCharCode(charCode);
			}
		});
	}

	private static function enter(){
		go(currentInput);
		runCommand(currentInput);
		currentInput = '';
	}

	private static function backspace(){
		currentInput = currentInput.substring(0, currentInput.length - 1);
	}

	public static function runCommand(command : String){
        if(commands == null){
            trace(go('No commands exist.'));
            return;
        }
        var args = smartSplit(command);
        if(args.length < 1){
            trace(go('Wtf you trying to say?'));
            return;
        } else if(!commands.exists(args[0])){
            trace(go('Command "${args[0]}" not found.'));
            return;
        } else {
            var theFunction : Array<String> -> String;
            try{
                theFunction = commands.get(args[0]);
                try {
                    trace(go(theFunction(args.slice(1))));
                } catch(e2 : String){
                    trace(go('Wrong parameters for ${args[0]}'));
                }
            } catch (e : String){
                trace(go("Command not found: " + args[0]));
            }
            
        }
    }

	private static function smartSplit(str : String){
        str += ' ';
        var state = READING_SPACES;
        var start = 0;
        var args = [];
        for(i in 0...str.length){
            switch(state){
            	case READING_SPACES:
            		if(str.charAt(i) == ' '){
                        continue;
                    } else if(str.charAt(i) == '"'){
                        start = i;
                        state = READING_QUOTE;
                    } else {
                        start = i;
                        state = READING_PARAM;
                    }
              	case READING_QUOTE:
            		if(str.charAt(i) == '"'){
                        args.push(str.substring(start + 1, i));
                        state = READING_SPACES;
                        start = i + 1;
                    } else {
                        continue;
                    }
              	case READING_PARAM:
            		if(str.charAt(i) == ' '){
                        args.push(str.substring(start, i));
                        state = READING_SPACES;
                        start = i + 1;
                    } else {
                        continue;
                    }
        	}
        }
    	return args;
    }
	
	public function drawConsole(g : G){
		if(Log.isOpen){
			var oldAlpha = g.alpha;
			var oldFillColor = g.fillColor;
			var oldFont = g.font;
			g.alpha = 0.5;
			g.fillColor = Utils.convertColor(Utils.getColorRGB(0,0,0));
			g.fillRect(0, 0, getScreenWidth(), 30 + (rows.length) * 20);
			if(font != null) g.setFont(font);
			for(i in 0...rows.length){
				g.drawString(rows[i], 10, 5 + i * 20);
			}
			g.drawString('> ' + currentInput, 10, 5 + rows.length * 20);
			g.alpha = oldAlpha;
			g.fillColor = oldFillColor;
			g.setFont(oldFont);
		}
	}


	
	
}