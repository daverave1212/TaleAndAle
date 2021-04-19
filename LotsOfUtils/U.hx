
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
import com.stencyl.Data;

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
		createBlackBitmapData(w, h) : BitmapData
		
		stringContains(string, substring)
		splitString(string, delimiters)
		
		first(array)
		last(array)
		randomOf(array)
		getFirstNull(arr) : Int		= -1 if no null found, else its index
		
		isBetween(number, a, b)
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
		Log.isInitialized = false;
	}
	


	// File in/out
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



	// Scene functionality
	public static function layerExists(layerName){
		return engine.getLayerByName(layerName) != null;
	}
	public static function createLayerIfDoesntExist(layerName : String, ?zIndex : Int){
		if(engine.getLayerByName(layerName) == null){
			if(zIndex == null) zIndex = 99;
			addBackgroundFromImage(null, false, layerName, zIndex);
		}
	}
	public static function changeScene(sceneName: String, fadeOutTimeSeconds: Float = 0.5, fadeInTimeSeconds: Float = 0.5) {
		if (fadeOutTimeSeconds >= 10 || fadeInTimeSeconds >= 10) trace('WARNING: For changeScene with fadeOut $fadeOutTimeSeconds and fadeIn $fadeInTimeSeconds, are you sure these are seconds and not miliseconds?');
		var sceneID = GameModel.get().scenes.get(getIDForScene(sceneName)).getID();
		var fo = createFadeOut(fadeOutTimeSeconds, Utils.getColorRGB(0,0,0));
		var fi = createFadeIn(fadeInTimeSeconds, Utils.getColorRGB(0,0,0));
		switchScene(sceneID, fo, fi);
		Sayer.reset();
		U.start();
	}



	// Math and probability
	public static inline function percentOf(value : Float, ofWhat : Float) return ofWhat * value / 100;
	public static inline function whatPercentOf(value : Float, ofWhat : Float) return value * 100 / ofWhat;
	public static function percentChance(percent : Float) : Bool {
		if (randomFloatBetween(0, 100) <= percent) return true;
		else return false;
	}
	public static function probabilityDistribution(distribution : Array<Int>) : Int {
		if (distribution == null) throw 'ERROR: null distribution given to distributionIndex';
		if (distribution.length == 0) return -1;
		var balls = [];
		for (index in 0...distribution.length)
			for (time in 0...distribution[index])
				balls.push(index);
		return balls[randomInt(0, balls.length - 1)];
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
	public static function toInt(f : Float){
		return Std.int(f);
	}
	public static function randomOf(a : Array<Dynamic>) : Dynamic {
		return (a[randomInt(0, a.length - 1)]);
	}
	public static function randomIndex(a : Array<Dynamic>) {
		return randomInt(0, a.length - 1);
	}
	public static function arraySumInt(a : Array<Int>) {
		var sum = 0;
		for (elem in a) sum += elem;
		return sum;
	}
	public static function angleBetweenPoints(x1 : Float, y1 : Float, x2 : Float, y2 : Float){
		return Utils.DEG * Math.atan2(y1-y2, x1-x2);
	}
	public static inline function isBetween(i : Float, a : Float, b : Float) return a <= i && i < b;
	public static inline function floatSum(a : Array<Float>){
		var x : Float = 0;
        for(e in a)
            x += e;
        return x;
	}
	public static inline function throwAndLogError(msg: String) {
		Log.go('ERROR: ${msg}');
		trace('ERROR: ${msg}');
	}
	


	// Events
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
	public static function onKeyPress(func){
		if(u == null) trace("ERROR: U not initialized!");
		u.addAnyKeyPressedListener(function(event:KeyboardEvent, list:Array<Dynamic>){
			func(event.charCode);
		});
	}
	public static function onGameKeyPress(func) {
		if(u == null) trace("ERROR: U not initialized!");
		u.addKeyStateListener("up", function(pressed:Bool, released:Bool, list:Array<Dynamic>):Void {
			func();
		});
	}
	public static function getScreenXCenter() return getScreenX() + getScreenWidth() / 2;
	public static function getScreenYCenter() return getScreenY() + getScreenHeight() / 2;


	
	// General utilities
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
	public static function pass() trace('Pass...');
	public static function getFontByName(fontName : String) : Font {
		for (res in Data.get().resources) {
			if (res != null) trace(res.name);
			if (Std.is(res, Font) && res.name == fontName) {
				return cast res;       
			}
		}
		throw 'ERROR: No font with name $fontName found';
		return null;
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


	// Actor utilities
	public static function flipActorHorizontally(a : Actor) a.growTo(-1, 1, 0, Easing.linear);
	public static function unflipActorHorizontally(a : Actor) a.growTo(1, 1, 0, Easing.linear);
	public static function flipActorVertically(a : Actor) a.growTo(1, -1, 0, Easing.linear);
	public static function flipActorToLeft(a : Actor) a.growTo(1, 1, 0, Easing.linear);
	public static function flipActorToRight(a : Actor) a.growTo(-1, 1, 0, Easing.linear);
	public static function setXCenter(a : Actor, x : Float) a.setX(x - a.getWidth() / 2);
	public static function setYCenter(a : Actor, y : Float) a.setY(y - a.getHeight() / 2);
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
	public static function flashWhite(actor : Actor, durationInMiliseconds: Int, ?callback : Void -> Void) {
		actor.setFilter([createBrightnessFilter(100)]);
		doAfter(durationInMiliseconds, () -> {
			actor.clearFilters();
			if (callback != null) callback();
		});
	}
	public static function flashRed(actor : Actor, durationInMiliseconds: Int, ?callback : Void -> Void) {
		actor.setFilter([createTintFilter(Utils.getColorRGB(255,0,51), 100/100)]);
		doAfter(durationInMiliseconds, () -> {
			actor.clearFilters();
			if (callback != null) callback();
		});
	}

	


	public static function createBlackBitmapData(width, height) {
		var blackSquare = newImage(Std.int(width / Engine.SCALE), Std.int(height / Engine.SCALE));
		fillImage(blackSquare, Utils.getColorRGB(0, 0, 0));
		return blackSquare;
	}



	

	

	
	

	
	
}


