

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

import com.stencyl.graphics.shaders.BasicShader;
import com.stencyl.graphics.shaders.GrayscaleShader;
import com.stencyl.graphics.shaders.SepiaShader;
import com.stencyl.graphics.shaders.InvertShader;
import com.stencyl.graphics.shaders.GrainShader;
import com.stencyl.graphics.shaders.ExternalShader;
import com.stencyl.graphics.shaders.InlineShader;
import com.stencyl.graphics.shaders.BlurShader;
import com.stencyl.graphics.shaders.SharpenShader;
import com.stencyl.graphics.shaders.ScanlineShader;
import com.stencyl.graphics.shaders.CSBShader;
import com.stencyl.graphics.shaders.HueShader;
import com.stencyl.graphics.shaders.TintShader;
import com.stencyl.graphics.shaders.BloomShader;


/*
		Extra API
	.play()				starts playing the text from the beginning
	.stop()				stops playing the text
	.resume()			continues to play the text
	.interval			0.05 by default
	.isTextPlaying()	returns true if it's playing, false if it's not
	NOTE: Requires TextBox.hx
*/

class TextBoxPlayable extends TextBox{

	
	public var interval		: Float = 0.02;
	
	private var currentLine	 	: Int = 0;
	private var currentLetter	: Int = 0;
	private var isPlaying		: Bool = false;
	private var playingText		: Array<String>;

	public function play(){
		currentLine = 0;
		currentLetter = 0;
		isPlaying = true;
	}
	
	public function stop(){
		isPlaying = false;
	}
	
	public function resume(){
		isPlaying = true;
	}
	
	public function isTextPlaying(){
		return isPlaying;
	}
	
	public function new(width : Int, height : Int, _x : Float, _y : Float, f : Font){
		super(width, height, _x, _y, f);
		playingText = new Array<String>();
		playingText[0] = "";
		runPeriodically(1000 * interval, function(timeTask:TimedTask):Void{
			if(isPlaying){
				if(currentLetter < lines[currentLine].length){
					playingText[currentLine] += lines[currentLine].charAt(currentLetter);
					currentLetter++;}
				else{
					currentLetter = 0;
					if(currentLine < lines.length - 1){
						currentLine++;
						playingText[currentLine] = "";}
					else{
						isPlaying = false;
					}
				}
			}
		},null);
	}
	
	public override function reset(){
		isPlaying = false;
		isDrawing = false;
		playingText = new Array<String>();
		playingText[0] = "";
		lines = new Array<Dynamic>();
		text = "";
		nLines = 0;}

	private override function draw(g : G){
		if(isDrawing){
			if(drawOutline){
				g.strokeColor = Utils.getColorRGB(255,200,0);
				g.strokeSize = 4;
				g.drawRect(x, y, w, h);
			}
			g.setFont(font);
			for(currentLine in 0...currentLine + 1){
				var drawx = x;
				var drawy = y;
				if(centerHorizontally){
					drawx = x + (w - font.font.getTextWidth(lines[currentLine]))/2;
				}
				if(centerVertically){
					drawy = y + (h - lineSpacing * nLines) / 2 + lineSpacing * currentLine;
				} else {
					drawy = y + lineSpacing * currentLine;
				}
				g.drawString(playingText[currentLine], drawx, drawy);}}}

}