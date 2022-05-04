

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
 * TextBox:
 * the constructor takes width, height, xposition and yposition
 * Use .setText(String) to set it's text
 * Then simply call startDrawing()
 * Use stopDrawing() to stop drawing
 *
 * You can also set .centerVertically .centerHorizontally and .drawOutline to true!
 *
 * NOTE: Don't forget to uncomment the package at the top of the code!
 * NOTE: The coordinates are SCENE COORDINATES!
 */
 
 /* API:

	.centerHorizontally = true	-- Aligns text center AND centers text on x
	.centerVertically   = true	-- Centers text on y
 
	new(width, height, x, y, font)
	.startDrawing()
	.stopDrawing()
	
 	.setText(String)
	.getText()	//returns a String
	.setPosition(x : Float, y : Float)
	.setSize(width : Int, height : Int)
	.reset()
	.x
	.y
	.w
	.h
	.nLines
	.lineSpacing	//default is 20
	.font
 
 */

class TextBox extends SceneScript{
	
	public var lines 		:Array<String>;
	public var w			:Int = 400;
	public var h			:Int = 400;
	public var x			:Float = 50;
	public var y			:Float = 50;
	public var nLines		:Int = 0;
	public var lineSpacing	:Float = 20;
	public var font			:Font;
	public var isDrawing	:Bool = false;
	
	public var centerHorizontally	:Bool = false;
	public var centerVertically 	:Bool = false;
	public var drawOutline 			:Bool = false;
	
	private var text		:String;
	
	public function new(width : Int, height : Int, _x : Float, _y : Float, f : Font){
		super();
		font = f;
		create(width, height, _x, _y, "");
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void {
			draw(g);
		});
	}

	public function getActualHeight(): Float {
		if (nLines == 0) return 0;
		if (nLines == 1) return font.getHeight() / Engine.SCALE;
		return (nLines - 1) * lineSpacing + font.getHeight() / Engine.SCALE;
	}
	
	public function reset(){
		isDrawing = false;
		lines = [];
		text = "";
		nLines = 0;}

	public function create(width : Int, height : Int, X : Float, Y : Float, t : String){
		lines = [];
		x = X;
		y = Y;
		h = height;
		w = width;
		setText(t);}

	public function setSize(width : Int, height : Int){
		w = width;
		h = height;}
	
	public function setPosition(_x : Float, _y : Float){
		x = _x;
		y = _y;}

	public function setText(t : String){
		var oldIsDrawing = isDrawing;
		reset();
		text = t;
		var wordList: Array<String> = U.smartSplitString(text, [' '], ['\n']);
		// var wordList: Array<String> = text.split(" ");
		nLines = 0;
		var currentLine = '';

		for (i in 0...wordList.length) {
			var word = wordList[i];
			if (word == '\n') {
				lines.push(currentLine);
				currentLine = '';
			} else if (getLineWidth(currentLine + ' ' + word) >= w) {
				lines.push(currentLine);
				currentLine = word;
			} else if (i == 0 || wordList[i-1] == '\n') {
				currentLine = word;
			} else {
				currentLine += ' ' + word;
			}
		}
		if (currentLine != '') lines.push(currentLine);
		nLines = lines.length;
		if (oldIsDrawing) startDrawing();
	}

	public function getText(){
		return text;}

	private function draw(g : G){
		if (!isDrawing) return;
		if (drawOutline) {
			g.strokeColor = Utils.getColorRGB(255,200,0);
			g.strokeSize = 4;
			final rectX = x - getScreenX() - if (centerHorizontally) w/2 else 0;
			final rectY = y - getScreenY() - if (centerVertically) h/2 else 0;
			g.drawRect(rectX, rectY, w, h);
		}
		var oldFont = g.font;
		g.setFont(font);
		for (currentLine in 0...nLines) {
			var drawx = x - getScreenX();
			if (centerHorizontally){
				drawx = x - getLineWidth(lines[currentLine]) / 2  - getScreenX();
			}
			var drawy = y + lineSpacing * currentLine - getScreenY();
			if (centerVertically) {
				final offsetY = nLines * lineSpacing / 2 + lineSpacing / 2;
				drawy -= offsetY;
			}
			g.drawString(lines[currentLine], drawx, drawy);
			if (drawOutline) {
				g.strokeColor = Utils.getColorRGB(0,0,0);
				g.strokeSize = 1;
				g.drawRect(drawx, drawy, getLineWidth(lines[currentLine]), lineSpacing);
			}
		}
		g.setFont(oldFont);
	}

	public function startDrawing(){
		isDrawing = true;}
		
	public function stopDrawing(){
		isDrawing = false;}

	function getLineWidth(line : String) return font.font.getTextWidth(line) / Engine.SCALE;

}
