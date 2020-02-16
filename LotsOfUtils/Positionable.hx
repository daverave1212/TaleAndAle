

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

import U.*;
using U;

class Positionable
{	
    // Override these
	public function getX(){return 0.0;}
    public function getY(){return 0.0;}
    public function setX(x : Float){}
    public function setY(y : Float){}
    public function getWidth() return 0.0;
    public function getHeight() return 0.0;

    // Don't override these
	public function getXScreen() return getX() - Std.int(getScreenX());
	public function getYScreen() return getY() - Std.int(getScreenY());
	public function setXScreen(x : Float) setX(getX() + Std.int(getScreenX()));
	public function setYScreen(y : Float) setY(getY() + Std.int(getScreenY()));
	public function addX(x : Float) setX(getX() + x);
	public function addY(y : Float) setY(getY() + y);
	public function setXY(x : Float, y : Float){ setX(x); setY(y); }
	public function setLeft(value : Float){ setX(getScreenX() + value); return this; }
	public function setLeftFrom(value : Float, offset : Float){ setX(value + offset); return this; }
	public function setRight(value : Float){ setX(getScreenX() + getScreenWidth() - getWidth() - value); return this; }
	public function setRightFrom(value : Float, offset : Float){ setX(offset - getWidth() - value); return this; }
	public function setTop(value : Float){ setY(getScreenY() + value); return this; }
	public function setTopFrom(value : Float, offset : Float){ setY(value + offset); return this; }
	public function setBottom(value : Float){ setY(getScreenY() + getScreenHeight() - getHeight() - value); return this; }
	public function setBottomFrom(value : Float, offset : Float){ setY(offset - getHeight() - value); return this; }
	public function getBottom() return getY() + getHeight();
	public function getRight() return getX() + getWidth();
	public function getLeft() return getX();
	public function getTop() return getY();
	public function centerVertically(){ setTop(getScreenHeight() / 2 - getHeight() / 2); return this; }
	public function centerHorizontally(){ setLeft(getScreenWidth() / 2 - getWidth() / 2); return this; }
	public function centerOnScreen(){
		setX(getScreenX() + (getScreenWidth() - getWidth()) / 2);
		setY(getScreenY() + (getScreenHeight() - getHeight()) / 2);
		return this;
	}

}

















