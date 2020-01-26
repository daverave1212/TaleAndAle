
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
	
	--- REQUIRES:
		ImageX.hx		[Because of sliding images]

	API:
		start()
		changeScene(sceneName, ?fadeIn, ?fadeOut)
		createLayerIfDoesntExist(layerName)
		
		repeat(func, interval)
		onDraw(function(g))
		onClick(function())
		onClick(function(a), actor)
		onRelease(function())
		onRelease(function(a), actor)
		
		hexToDecimal
		getColor(r, g, b) 	: Int       all ints
		getColor('#FFFFFF') : Int
		
		
		stringContains(string, substring)
		splitString(string, delimiters)
		
		first(array)
		last(array)
		randomOf(array)
		getFirstNull(arr) : Int		= -1 if no null found, else its index
		
		angleBetweenPoints(x1, y1, x2, y2)
		getBitmapDataSize(bitmapData) : Vector2Int
		
		createActor(actorTypeName, layerName)
		createActor(actorType, layerName)
		flipActorHorizontally(actor)
		flipActorVertically(actor)
		


"*/

class U extends SceneScript
{

	// Constructor only exists so it can add event listeners
	private function new(){super();}
	public static var u : U;
	public static function getInstance(){ return u; }
	
	// This must be done once per scene.
	// Called automatically from U.changeScene(..)
	public static function start(){
		u = new U();
		ImageX._startSlidingImages();
		UIManager.init();
	}
	
	public static function readFile(fileName : String) : String {
		return nme.Assets.getText("assets/data/" + fileName);
	}
	
	public static function parseJSON(jsonString : String){
		return haxe.Json.parse(jsonString);
	}
	
	public static function readJSON(fileName : String) {
		var text = readFile(fileName);
		return parseJSON(text);
	}

	public static function layerExists(layerName){
		return engine.getLayerByName(layerName) != null;
	}
	
	public static function createLayerIfDoesntExist(layerName : String, ?zIndex : Int){
		if(engine.getLayerByName(layerName) == null){
			if(zIndex == null) zIndex = 99;
			addBackgroundFromImage(null, false, layerName, zIndex);
		}
	}

	public static inline function percentOf(value : Float, ofWhat : Float){
		return ofWhat * value / 100;
	}

	public static inline function whatPercentOf(value : Float, ofWhat : Float){
		return value * 100 / ofWhat;
	}
	
	public static function pass(){
		trace('Pass...');
	}

	public static function hexToDecimal(stringHex){
		stringHex = "0x" + stringHex;
		return Std.parseInt(stringHex);
	}
	
	public static function getColor(?asString : String, ?r : Int, ?g : Int, ?b : Int){
		if(asString != null){
			if(asString.length < 6){
				trace("COLOR " + asString + " not a color.");
				return Utils.getColorRGB(255, 0, 255);			// Returns magenta if error
			} else {
				if(asString.charAt(0) == '#'){
					asString = asString.substring(1);	// If starts with #, removes it
				}
				return hexToDecimal(asString);
			}
		} else {
			return Utils.getColorRGB(r, g, b);
		}
	}
	
	public static function onDraw(func : G->Void){
		if(u == null){
			trace("ERROR: U not initialized!!");
			return;
		}
		u.addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			func(g);
		});
	}
	
	public static function onClick(?func : Void->Void, ?actorFunc : Actor->Void, ?actor : Actor){
		if(u == null){
			trace("ERROR: U not initialized!!");
			return;
		}
		if(actor == null){
			u.addMousePressedListener(function(list:Array<Dynamic>):Void{
				func();
			});
		} else {
			u.addMouseOverActorListener(actor, function(mouseState:Int, list:Array<Dynamic>):Void{
				if(mouseState == 3){
					if(func != null){
						func();
					}
					if(actorFunc != null) actorFunc(actor);
				}
			});
		}
	}
	
	public static function onEnter(func : Void->Void, actor : Actor){
		u.addMouseOverActorListener(actor, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(1 == mouseState){
				func();
			}
		});
	}
	
	public static function onExit(func : Void->Void, actor : Actor){
		u.addMouseOverActorListener(actor, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(-1 == mouseState){
				func();
			}
		});
	}
	
	
	public static function onRelease(?func : Void->Void, ?actorFunc : Actor->Void, ?actor : Actor){
		if(u == null){
			trace("ERROR: U not initialized!!");
			return;
		}
		if(actor == null){
			u.addMouseReleasedListener(function(list:Array<Dynamic>):Void{
				func();
			});
		} else {
			u.addMouseOverActorListener(actor, function(mouseState:Int, list:Array<Dynamic>):Void{
				if(mouseState == 5){
					if(func != null) func();
					if(actorFunc != null) actorFunc(actor);
				}
			});
		}
	}
	
	
	public static function repeat(func : Void->Void, interval){
		runPeriodically(interval, function(timeTask:TimedTask):Void{
			func();
		}, null);
	}
	public static var setInterval = repeat;
	
	public static function doAfter(miliseconds : Int, doThis : Void -> Void){
		runLater(miliseconds, function(timeTask:TimedTask):Void{
			doThis();
		}, null);
	}

	public static function changeScene(sceneName : String, ?fadeOut : Dynamic, ?fadeIn : Dynamic){
		var sceneID = GameModel.get().scenes.get(getIDForScene(sceneName)).getID();
		var fo = null;
		var fi = null;
		if(fadeOut == null){
			fo = createFadeOut(0, Utils.getColorRGB(0,0,0));
		}
		if(fadeIn == null){
			fi = createFadeIn(0, Utils.getColorRGB(0,0,0));
		}
		trace("Changing scene to " + sceneID);
		switchScene(sceneID, fo, fi);
		trace("Starting U again...");
		U.start();
	}
	
	public static function stringContains(s : String, letter : String){
		for(i in 0...s.length){
			if(s.charAt(i) == letter){
				return s.charAt(i);
			}
		}
		return "";
	}
	
	public static function splitString(s : String, delimiters : String){
		trace('');
		trace('Splitting $s :');
		trace('Does it have \\n ?');
		trace(s.indexOf('\n'));
		var returnedArray : Array<String> = [];
		var lastLetterWasDelimiter = false;
		var firstCharIndex = 0;
		if(s.length > 0){
			while(stringContains(delimiters, s.charAt(firstCharIndex)) != "" && firstCharIndex < s.length){
				firstCharIndex++;
			} 
		}
		var start = firstCharIndex;
		trace('Starting at $start');
		var end = firstCharIndex;
		for(i in firstCharIndex...s.length){
			var letter = s.charAt(i);
			if(stringContains(delimiters, letter) != ""){
				trace('  Splitting at ${letter}');
				if(lastLetterWasDelimiter){
					start = i + 1;
				} else {
					trace('Pushing $start - $i ${s.substring(start, end)}');
					returnedArray.push(s.substring(start, end));
					start = i + 1;
					end = start;
				}
                lastLetterWasDelimiter = true;
			} else {
                lastLetterWasDelimiter = false;
				end = i + 1;
			}
		}
		trace('');
		if(!lastLetterWasDelimiter){
            returnedArray.push(s.substring(start));
        }
		trace(returnedArray);
		return returnedArray;
	}

	public static function toInt(f : Float){
		return Std.int(f);
	}

	public static function randomOf(a : Array<Dynamic>){
		return(a[Std.random(a.length - 1)]);
	}
	
	public static function first<T>(a : Array<T>){
		if(a == null) return null;
		if(a.length == 0) return null;
		return a[0];
	}
	
	public static function last<T>(a : Array<T>){
		if(a == null) return null;
		if(a.length == 0) return null;
		return a[a.length - 1];
	}
	
	public static function angleBetweenPoints(x1 : Float, y1 : Float, x2 : Float, y2 : Float){
		return Utils.DEG * Math.atan2(y1-y2, x1-x2);
	}
	
	public static function flipActorHorizontally(a : Actor){
		a.growTo(-1, 1, 0, Easing.linear);
	}

	public static function flipActorVertically(a : Actor){
		a.growTo(1, -1, 0, Easing.linear);
	}
	
	public static function flipActorToLeft(a : Actor){
		a.growTo(1, 1, 0, Easing.linear);
	}
	
	public static function flipActorToRight(a : Actor){
		a.growTo(-1, 1, 0, Easing.linear);
	}
	
	public static function createActor(?actorTypeName : String, ?actorType : ActorType, layerName : String, ?_x : Float, ?_y : Float){
		if(actorTypeName != null){
			actorType = getActorTypeByName(actorTypeName);
		}
		var a : Actor = null;
		try {
			a = createRecycledActorOnLayer(actorType, 0, 0, engine.getLayerByName(layerName));
		} catch (e : String) {
			trace('ERROR: Failed to create unit');
		}
		if(_x != null) a.setX(_x);
		if(_y != null) a.setY(_y);
		return a;
	}
	
	public static function getBitmapDataSize(b : BitmapData) : Vector2Int{
		var img = new ImageX(b, "UI");
		var v = new Vector2Int(Std.int(img.getWidth()), Std.int(img.getHeight()));
		img.kill();
		return v;
	}
	
	public static function getFirstNull(a : Array<Dynamic>){
		for(i in 0...a.length){
			if(a[i] == null) return i;
		}
		return -1;
	}
	
	public static function setXCenter(a : Actor, x : Float) a.setX(x - a.getWidth() / 2);
	public static function setYCenter(a : Actor, y : Float) a.setY(y - a.getHeight() / 2);
	
}


