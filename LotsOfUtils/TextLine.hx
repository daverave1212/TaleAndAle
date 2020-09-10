

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


class TextLine {

	public static inline var ALIGN_RIGHT = 0;
	public static inline var ALIGN_LEFT = 1;
	public static inline var ALIGN_CENTER = 2;

	
	public static var defaultFont : Font;
	public static var hasDefaultFont = false;
	public static function useFont(f) defaultFont = f;

	public var text : String;
	public var x : Float = 0;
	public var y : Float = 0;
	public var font : Font;

	public var isDrawing = true;

	var alignment = ALIGN_RIGHT;
	var alignOffsetX : Float = 0;

	public function new(text, ?font, ?_x, ?_y) {
		this.text = text;
		if (font == null) {
			if (defaultFont == null) trace("ERROR: No TextLine defaultFont");
			this.font = defaultFont;
		} else {
			this.font = font;
		}
		if (_x != null) x = _x;
		if (_y != null) y = _y;
		U.onDraw(function(g : G){
			if (!isDrawing) return;
			g.setFont(this.font);
			g.drawString(this.text, this.x + alignOffsetX, this.y);
		});
	}

	public function setText(t : String) {
		this.text = t;
		if (alignment == ALIGN_LEFT)
			alignOffsetX = - this.font.getTextWidth(this.text) / Engine.SCALE;
		else if (alignment == ALIGN_CENTER)
			alignOffsetX = - (this.font.getTextWidth(this.text) / Engine.SCALE) / 2;
		else if (alignment == ALIGN_RIGHT)
			alignOffsetX = 0;
	}

	public function alignLeft() alignment = ALIGN_LEFT;
	public function alignCenter() alignment = ALIGN_CENTER;
	public function alignRight() alignment = ALIGN_RIGHT;
	public inline function setX(x) this.x = x;
	public inline function setY(y) this.y = y;
	public inline function disable() isDrawing = false;
	public inline function enable() isDrawing = true;

}
