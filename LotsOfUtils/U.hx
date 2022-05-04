
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

import Std.*;
import Math.*;

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
		Log.isOpen = false;
	}
	


	// File in/out
	public static function readFile(fileName : String) : String {
		return nme.Assets.getText("assets/data/" + fileName);
	}
	public static function parseJSON(jsonString : String) {
		return haxe.Json.parse(jsonString);
	}
	public static function readJSON(fileName : String) {
		var text = readFile(fileName);
		return parseJSON(text);
	}
	public static function gameAttributeExists(name): Bool {
		try {
			final attr: Any = getGameAttribute(name);
			if (attr == null || attr == '') return false;
			return true;
		} catch (e: Any) {
			return false;
		}
		return false;
	}
	public static function getStringGameAttributeOr(name: String, or: String) {
		var value: String = null;
		try {
			value = getGameAttribute(name);
		} catch (e: Any) {
			return or;
		}
		if (value == null || value == '') return or;
		return value;
	}

	// Scene functionality
	public static function getLayer(layerName: String) {
		return engine.getLayerByName(layerName);
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

	public static var defaultChangeSceneFadeTime = 0.5;
	public static function changeScene(sceneName: String, ?fadeOutTimeSeconds: Float = null, ?fadeInTimeSeconds: Float = null, ?andThen: Void -> Void) {
		if (fadeOutTimeSeconds == null) fadeOutTimeSeconds = defaultChangeSceneFadeTime;
		if (fadeInTimeSeconds == null) fadeInTimeSeconds = defaultChangeSceneFadeTime;
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
		if (distribution == null) throwAndLogError('ERROR: null distribution given to distributionIndex');
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
	// public static function randomOf(a : Array<Dynamic>) : Dynamic {
	// 	return (a[randomInt(0, a.length - 1)]);
	// }
	@:generic public static function randomOf<T>(a: Array<T>): T {
		return (a[randomInt(0, a.length - 1)]);
	}
	@:generic public static function last<T>(a: Array<T>): T {
		return a[a.length - 1];
	}

	@:generic public static function flattenOnce<T>(a: Array<Array<T>>): Array<T> {
		return null;
	}
	@:generic public static function times<T>(what: T, nTimes: Int): Array<T> {
		if (nTimes <= 0) return [];
		return [for (_ in 0...nTimes) what];
	}
	@:generic public static function pushTimes<T>(array: Array<T>, what: T, nTimes: Int): Void {
		for (_ in 0...nTimes) {
			array.push(what);
		}
	}
	@:generic public static function indices<T>(array: Array<T>): Array<Int> {
		return [for (i in 0...array.length) i];
	}
	public static function randomIndex(a : Array<Dynamic>) {
		return randomInt(0, a.length - 1);
	}
	public static function randomIntBetween(a, b) {
		return randomInt(a, b);
	}
	public static function arraySumInt(a : Array<Int>) {
		var sum = 0;
		for (elem in a) sum += elem;
		return sum;
	}
	@:generic public static function isOutOfBounds<T>(array: Array<T>, index: Int) {
		return index < 0 || index >= array.length;
	}
	public static function angleBetweenPoints(x1 : Float, y1 : Float, x2 : Float, y2 : Float){
		return Utils.DEG * Math.atan2(y1-y2, x1-x2);
	}
	public static function distanceBetweenPoints(x1: Float, y1: Float, x2: Float, y2: Float) {
		return Math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1));
	}
	public static function getMiddlePoint(x1: Float, y1: Float, x2: Float, y2: Float) {
		return new Point((x1 + x2)/2, (y1 + y2)/2);
	}
	public static inline function isBetween(i : Float, a : Float, b : Float) return a <= i && i < b;
	public static inline function floatSum(a : Array<Float>){
		var x : Float = 0;
        for(e in a)
            x += e;
        return x;
	}
	public static function calculateSlope(actor1: Actor, actor2: Actor): Float {
		// m = (y2 - y1) / (x2 - x1)
		var m: Float = (actor2.getY() - actor1.getY()) / (actor2.getX() - actor1.getX());
		return m;
	}
	public static function calculateIntercept(x: Float, y: Float, m: Float) {
		// c = y - mx
		var c: Float = y - m * x;
		return c;
	}

	public static function warnLog(msg: String) {
		if (!Log.isOpen) {
			Log.toggle();
		}
		Log.go('WARNING: ${msg}');
		trace('WARNING: ${msg}');
		return 'WARNING: ${msg}';

	}
	public static inline function throwAndLogError(msg: String) {
		if (!Log.isOpen) {
			Log.toggle();
		}
		trace('ERROR: ${msg}');
		doAfter(10, () -> {
			Log.go('ERROR: ${msg}');
		});
		doAfter(100, () -> {
			throw('ERROR: ${msg}');
		});
		return 'ERROR: ${msg}';
	}
	static function hexStringToInt(hexString: String) {
		final reversedHexStringChars = hexString.split('');
		reversedHexStringChars.reverse();
		final charIntMap = [
				'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
		  '8' => 8, '9' => 9, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15
		];
		var intNum = 0;
		for (i in 0...reversedHexStringChars.length) {
				intNum += Std.int(charIntMap[reversedHexStringChars[i]] * Math.pow(16, i));
		}
		  return intNum;
	  }
	


	// Events
	public static function onDraw(func : G->Void){
		if(u == null){
			throwAndLogError("ERROR: U not initialized!!");
			return;
		}
		u.addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			func(g);
		});
	}
	public static function onClick(?func : Void->Void, ?actorFunc : Actor->Void, ?actor : Actor){
		if(u == null){
			throwAndLogError("ERROR: U not initialized!!");
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
			throwAndLogError("ERROR: U not initialized!!");
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
	static var _lastClickedActor: Actor;
	public static function onClickAndRelease(func: Void -> Void, actor: Actor) {
		onClick(function(): Void {
			_lastClickedActor = actor;
		}, actor);
		onRelease(function(): Void {
			if (_lastClickedActor == actor) {
				func();
			}
		}, actor);
	}
	public static function onKeyPress(func){
		if(u == null) throwAndLogError("ERROR: U not initialized!!");
		u.addAnyKeyPressedListener(function(event:KeyboardEvent, list:Array<Dynamic>){
			func(event.charCode);
		});
	}
	public static function onGameKeyPress(func) {
		if(u == null) throwAndLogError("ERROR: U not initialized!!");
		u.addKeyStateListener("up", function(pressed:Bool, released:Bool, list:Array<Dynamic>):Void {
			func();
		});
	}
	public static function onEscapeKeyPress(func) {
		u.addKeyStateListener("escape", function(pressed:Bool, released:Bool, list:Array<Dynamic>):Void {
			if (pressed) {
				func();
			}
		});
	}
	public static function getScreenXCenter() return getScreenX() + getScreenWidth() / 2;
	public static function getScreenYCenter() return getScreenY() + getScreenHeight() / 2;
	public static function getScreenYBottom() return getScreenY() + getScreenHeight();
	public static function getScreenXRight() return getScreenX() + getScreenWidth();

	public static var defaultMusicVolume: Float = 0.33;
	public static function playAudio(audioName: String, ?channelNumber: Int = -1): Int {
		final MUSIC_CHANNEL = 1;
		if (channelNumber != -1) {
			if (channelNumber == MUSIC_CHANNEL) {
				fadeOutSoundOnChannel(channelNumber, 0.5);
				doAfter(500, () -> {
					trace('Setting volume of channel ${channelNumber} to ${defaultMusicVolume}');
					stopSoundOnChannel(channelNumber);
					playSoundOnChannel(getSoundByName(audioName), channelNumber);
					setVolumeForChannel(defaultMusicVolume, channelNumber);
				});
			} else {
				playSoundOnChannel(getSoundByName(audioName), channelNumber);
			}
		} else {
			playSound(getSoundByName(audioName));
		}
		final durationInMiliseconds = int(getSoundLength(getSoundByName(audioName)));
		return durationInMiliseconds;
	}

	public static function playMusic(audioName: String) {
		final MUSIC_CHANNEL = 1;
		fadeOutSoundOnChannel(MUSIC_CHANNEL, 0.25);
		doAfter(250, () -> {
			stopSoundOnChannel(MUSIC_CHANNEL);
			loopSoundOnChannel(getSoundByName(audioName), MUSIC_CHANNEL);
			setVolumeForChannel(defaultMusicVolume, MUSIC_CHANNEL);
		});
	}
	public static function stopMusic() {
		final MUSIC_CHANNEL = 1;
		fadeOutSoundOnChannel(MUSIC_CHANNEL, 0.5);
		doAfter(500, () -> {
			stopSoundOnChannel(MUSIC_CHANNEL);
		});
	}
	public static function setChannelVolume(channelNumber: Int, volume: Float) {
		setVolumeForChannel(volume, channelNumber);
	}


	
	// General utilities
	public static inline function repeat(func, interval) return doEvery(interval, func);
	public static function doEvery(interval: Int, funcToRepeat : Void->Void, ?actor: Actor = null) {
		return runPeriodically(interval, function(timeTask:TimedTask):Void{
			funcToRepeat();
		}, actor);
	}

	public static function doEveryUntil(miliseconds: Int, untilMiliseconds: Int, ?funcTakesTime: Int->Void, ?func: Void->Void) {
		var currentTime: Int = 0;
		var timedTask: TimedTask;
		timedTask = doEvery(miliseconds, function(): Void {
			if (currentTime >= untilMiliseconds && timedTask != null) {
				timedTask.repeats = false;
				return;
			}
			if (funcTakesTime != null)
				funcTakesTime(currentTime);
			else
				func();
			currentTime += miliseconds;
		});
	}
	public static var setInterval = repeat;
	public static inline function doAfter(miliseconds : Float, doThis : Void -> Void){
		return runLater(Std.int(miliseconds), (timeTask:TimedTask) -> {
			doThis();
		}, null);
	}
	public static function doAfterSafe(miliseconds: Int, doThis: Void -> Void) {	// A 'safe' version of doAfter; Only does it if it's the same scene and if it's not a null function.
		final sceneName = getCurrentSceneName();
		return doAfter(miliseconds, () -> {
			if (getCurrentSceneName() != sceneName) return;
			if (doThis != null) doThis();
		});
	}

	public static function doSequence(sequence: Array<{time: Int, func: Void -> Void}>, ?andThen: Void -> Void): Dynamic {
		if (sequence.length == 0) {
			if (andThen != null) andThen();
			return {};
		} else {
			var isStopped = false;
			function stopSequence() {
				isStopped = true;
			}
			final firstPair = sequence.shift();
			final timeToWait: Int = firstPair.time;
			final funcToDo: Void -> Void = firstPair.func;
			doAfter(timeToWait, function(): Void {
				if (isStopped) return;
				funcToDo();
				doSequence(sequence, andThen);
			});
			return {
				stop: stopSequence
			};
		}

	}

	public static function isStringNumber(str: String) {
		final digits = '0123456789';
		var foundDot = false;
		for (char in str.split('')) {
			if (char == '.') {
				if (foundDot == false) {
					foundDot = true;
				} else {
					return false;
				}
			} else if (digits.indexOf(char) != -1) {
				continue;
			} else {
				return false;
			}
		}
		return true;
	}
	public static function setObjectFieldSmart(object: Dynamic, fieldName: String, value: String) {
		if (value == 'true' || value == 'false') {
			Reflect.setField(object, fieldName, if (value == 'true') true else false);
			return;
		}
		if (!isStringNumber(value)) {
			Reflect.setField(object, fieldName, value);
			return;
		}
		if (value.indexOf('.') == -1) {
			final intValue: Int = Std.parseInt(value);
			Reflect.setField(object, fieldName, intValue);
		} else {
			final floatValue: Float = Std.parseFloat(value);
			Reflect.setField(object, fieldName, floatValue);
		}


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
	static inline var READING_WORD = 0;
	static inline var DELIMITING = 1;
	public static function smartSplitString(s: String, excludeDelimiters: Array<String>, includeDelimiters: Array<String>) {
		
		var state = READING_WORD;
		var currentWordStart = 0;
		var currentWords: Array<String> = [];
		for (i in 0...s.length) {
			final char = s.charAt(i);
			final foundExcludeDelimiter = () -> {
				return excludeDelimiters.indexOf(char) != -1;
			};
			final foundIncludeDelimiter = () -> includeDelimiters.indexOf(char) != -1;
			switch (state) {
				case READING_WORD:
					if (foundExcludeDelimiter()) {
						currentWords.push(s.substring(currentWordStart, i));
						currentWordStart = -1;
						state = DELIMITING;
					} else if (foundIncludeDelimiter()) {
						currentWords.push(s.substring(currentWordStart, i));
						currentWords.push(char);
						currentWordStart = -1;
						state = DELIMITING;
					} else {
						// pass
					}
				case DELIMITING:
					if (foundIncludeDelimiter()) {
						currentWords.push(char);
					} else if (foundExcludeDelimiter()) {
						// pass
					} else {
						currentWordStart = i;
						state = READING_WORD;
					}
			}
		}
		if (state == READING_WORD && currentWordStart != -1) {
		currentWords.push(s.substring(currentWordStart, s.length));
		}
		return currentWords;
	}
	
	public static function first<T>(a : Array<T>){
		if(a == null) return null;
		if(a.length == 0) return null;
		return a[0];
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
	@:generic public static function mergeArrays<T>(arrays: Array<Array<T>>) {
		var finalArray: Array<T> = [];
		for (array in arrays) {
			finalArray = finalArray.concat(array);
		}
		return finalArray;
	}
	@:generic public static function removeDuplicates<T>(array: Array<T>): Array<T> {
		final elementsMap: Map<T, Bool> = [];
		for (elem in array) {
			elementsMap[elem] = true;
		}
		final arrayNoDupes: Array<T> = [];
		for (elem in elementsMap.keys()) {
			arrayNoDupes.push(elem);
		}
		return arrayNoDupes;
	}
	@:generic public static function shuffle<T>(array: Array<T>): Void {
		for (i in 0...array.length) {
			final aux = array[i];
			final indexToSwap = randomIntBetween(0, array.length - 1);
			array[i] = array[indexToSwap];
			array[indexToSwap] = aux;
		}
	}

	public static function alterJSONValue(key: String, value: String) {

	}

	public static function nullOr(maybeNull: Any, notNull: Any): Any {
		if (maybeNull == null) return notNull;
		return maybeNull;
	}



	// Actor utilities
	public static function centerActorOnScreen(a: Actor) {
		a.setXCenter(getScreenXCenter());
		a.setYCenter(getScreenYCenter());
	}
	public static function flipActorHorizontally(a : Actor, seconds: Float = 0) a.growTo(-1, 1, seconds, Easing.expoOut);
	public static function unflipActorHorizontally(a : Actor, seconds: Float = 0) a.growTo(1, 1, seconds, Easing.expoOut);
	public static function flipActorVertically(a : Actor) a.growTo(1, -1, 0, Easing.linear);
	public static function flipActorToLeft(a : Actor) a.growTo(1, 1, 0, Easing.linear);
	public static function flipActorToRight(a : Actor) a.growTo(-1, 1, 0, Easing.linear);
	public static function setXCenter(a : Actor, x : Float) a.setX(x - a.getWidth() / 2);
	public static function setYCenter(a : Actor, y : Float) a.setY(y - a.getHeight() / 2);
	public static function killActor(a: Actor) {
		recycleActor(a);
	}
	public static function setYBottom(a: Actor, y: Float) {
		a.setY(y - a.getHeight());
	}
	public static function getActorCenterPoint(a: Actor) {
		return new Point(a.getXCenter(), a.getYCenter());
	}
	public static function createActor(?actorTypeName : String, ?actorType : ActorType, layerName : String, ?_x : Float, ?_y : Float) {
		if (actorTypeName != null){
			actorType = getActorTypeByName(actorTypeName);
		}
		var a : Actor = null;
		try {
			a = createRecycledActorOnLayer(actorType, 0, 0, engine.getLayerByName(layerName));
		} catch (e : String) {
			throw 'ERROR: Failed to create unit of type name ${actorTypeName} on layer ${layerName}';
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
	public static function flashColor(actor : Actor, r: Float, g: Float, b: Float, ?callback : Void -> Void) {
		actor.setFilter([createTintFilter(Utils.getColorRGB(int(r),int(g),int(b)), 100/100)]);
		doAfter(500, () -> {
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
	public static function slideActorX(a: Actor, from: Float, to: Float, overMiliseconds: Int) {
		var directionXModifier = if (from < to) 1 else -1;
		var distanceX = abs(from - to);
		var everyMilisecondsStep = 16;		// Every 50 miliseconds
		var time = overMiliseconds;
		var nSteps = int(time / everyMilisecondsStep);
		var xStepSize = distanceX / nSteps;
		doEveryUntil(everyMilisecondsStep, time, (_) -> {
			a.setX(a.getX() + directionXModifier * xStepSize);
		});
	}
	public static function animateValue(fromValue: Float, toValue: Float, overMiliseconds: Int, setValue: Float -> Void) {
		final stepTime = 50;
		final nSteps = overMiliseconds / stepTime;
		doEveryUntil(10, overMiliseconds, (currentMiliseconds: Int) -> {
			setValue(getAnimatedValue(fromValue, toValue, overMiliseconds, currentMiliseconds));
		});
	}
	public static function getAnimatedValue(from: Float, to: Float, overMiliseconds: Int, atTime: Int) {
		final distance = from - to;
		final directionModifier = if (distance >= 0) -1 else 1;
		function getStepExponentialDistancePassed(currentMiliseconds) {
			var distancePassed = (1 - pow(1 - currentMiliseconds * (1/overMiliseconds), 2)) * abs(distance);
			return distancePassed;
		}
		return from + getStepExponentialDistancePassed(atTime) * directionModifier;
	}
	public static function slideActorYCubic(a: Actor, from: Float, to: Float, overMiliseconds: Int, ?reverseExpo = false) {	// Slides the actor with an easing function
		var distanceY = from - to;
		var directionYModifier = if (distanceY >= 0) -1 else 1;
		var everyMilisecondsStep = 16;		// Every 50 miliseconds
		var time = overMiliseconds;
		var nSteps = int(time / everyMilisecondsStep);
		function getStepExponentialYDistancePassed(currentMiliseconds) {
			var distancePassed = (1 - pow(1 - currentMiliseconds * (1/time), 2)) * abs(distanceY);
			return distancePassed;
		}
		function getStepExponentialYDistancePassedReverse(currentMiliseconds) {
			var distancePassed = pow((currentMiliseconds/time), 2) * abs(distanceY);
			return distancePassed;
		}
		var expoFunction = if (reverseExpo) getStepExponentialYDistancePassedReverse else getStepExponentialYDistancePassed;
		doEveryUntil(everyMilisecondsStep, time, (currentMiliseconds) -> {
			a.setY(from + expoFunction(currentMiliseconds) * directionYModifier);
		});
	}
	public static function setActorScreenRight(a: Actor, r: Float) {
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - r);
	}
	public static function rotateActorCCWAroundPointFacingPoint(options: {
		actor: Actor,
		x: Float,
		y: Float,
		degrees: Float,
		?radius: Float
	}) {
		
		final actor = options.actor;

		// Because the origin/rotation point of an actor is its center and we move it to the left side
		// So xPoint is the final rotation radius; width/2 means the left-most point of the actor = 0 radius
		final xPoint = actor.getWidth() / 2 + if (options.radius != null) options.radius else 0;

		actor.setX(options.x);
		actor.setY(options.y);
		actor.rotate(-Utils.RAD * options.degrees);

		final alpha = actor.getAngle() * Utils.DEG;
		final xOffset = Math.cos(alpha * Utils.RAD) * xPoint;
		final yOffset = Math.sin(alpha * Utils.RAD) * xPoint;

		actor.setX(actor.getX() + xOffset - actor.getWidth()/2);
		actor.setY(actor.getY() + yOffset - actor.getHeight()/2);
	}
	public static function setActorSaturation(actor: Actor, percentage: Float) {
		if (percentage > 0 && percentage < 1) trace('WARNING: In setActorSaturation, was expecting percentage ${percentage} between 0 and 100, not between 0 and 1.');
		actor.setFilter([createSaturationFilter(percentage)]);
	}
	public static function tintActorByAmount(actor: Actor, color: String, percentage: Float) {
		if (percentage > 0 && percentage < 1) trace('WARNING: In tintActorByAmount, was expecting percentage ${percentage} between 0 and 100, not between 0 and 1.');
		final red = hexStringToInt(color.substring(0, 2));
		final green = hexStringToInt(color.substring(2, 4));
		final blue = hexStringToInt(color.substring(4, 6));
		actor.setFilter([createTintFilter(Utils.getColorRGB(red, green, blue), percentage / 100)]);
	}
	public static function stretchActorBetweenPoints(actor: Actor, x1: Float, y1: Float, x2: Float, y2: Float) {
		final angle = angleBetweenPoints(x1, y1, x2, y2);
		final width = distanceBetweenPoints(x1, y1, x2, y2);
		final middlePoint = getMiddlePoint(x1, y1, x2, y2);
		final xScale = width / actor.getWidth();
		actor.setXCenter(middlePoint.x);
		actor.setYCenter(middlePoint.y);
		actor.setAngle(Utils.RAD * angle);
		actor.growTo(xScale, 1, 0.04, Easing.linear);
	}
	
	
	
	public static function slideCameraXCubic(to: Float, overMiliseconds: Int) {
		final from = getScreenXCenter();
		final distanceX = from - to;
		final time = overMiliseconds;
		final everyMilisecondsStep = 10;
		final nSteps = int(time / everyMilisecondsStep);
		function getStepExponentialXDistancePassed(currentMiliseconds) {
			final distancePassed = (1 - pow(1 - currentMiliseconds * (1/time), 2)) * abs(distanceX);
			return distancePassed;
		}
		final directionXModifier = if (distanceX >= 0) -1 else 1;
		doEveryUntil(everyMilisecondsStep, time, (currentMiliseconds) -> {
			engine.moveCamera(from + getStepExponentialXDistancePassed(currentMiliseconds) * directionXModifier, getScreenY());
		});
	}
	public static function centerCameraInScene() {
		engine.moveCamera(getSceneWidth() / 2, getSceneHeight() / 2);
	}

	// Other

	public static function createBlackBitmapData(width, height) {
		var blackSquare = newImage(Std.int(width / Engine.SCALE), Std.int(height / Engine.SCALE));
		fillImage(blackSquare, Utils.getColorRGB(0, 0, 0));
		return blackSquare;
	}



	

	

	
	

	
	
}


