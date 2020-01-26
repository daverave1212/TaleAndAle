

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
 */
 
 /* API:
 
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
	
	public var lines 		:Array<Dynamic>;
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
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			draw(g);
			});}
	
	public function reset(){
		isDrawing = false;
		lines = new Array<Dynamic>();
		text = "";
		nLines = 0;}

	public function create(width : Int, height : Int, X : Float, Y: Float, t : String){
		lines = new Array<Dynamic>();
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
		reset();
		text = t;
		var wordList	: Array<Dynamic> = text.split(" ");
		var currentLine	: Int = 0;
		var currentWord : Int = 0;
		nLines = 0;
		while(currentWord < wordList.length){ //while currentLine width < w
			nLines++;
			lines[currentLine] = "";
			while(font.font.getTextWidth(lines[currentLine] + " " + wordList[currentWord]) / Engine.SCALE < w && wordList[currentWord] != "\n" && currentWord < wordList.length){
				lines[currentLine] += " " + wordList[currentWord];
				currentWord++;}
			currentLine++;
			if(wordList[currentWord] == "\n"){
				currentWord++;}}}
				
	public function getText(){
		return text;}
		
	private function draw(g : G){
		if(isDrawing){
			if(drawOutline){
				g.strokeColor = Utils.getColorRGB(255,200,0);
				g.strokeSize = 4;
				g.drawRect(x, y, w, h);
			}
			g.setFont(font);
			for(currentLine in 0...nLines){
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
				g.drawString(lines[currentLine], drawx, drawy);
				
			}}}
	
	public function startDrawing(){
		isDrawing = true;}
		
	public function stopDrawing(){
		isDrawing = false;}

}
