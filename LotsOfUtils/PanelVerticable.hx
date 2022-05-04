
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
import Std.int;

class PanelVerticable extends Positionable {

    public var imageTop: ImageX;
    public var imageMiddle: ImageX;
    public var imageBottom: ImageX;
    public var lastRecalculatedHeight: Float = 0;

    public function new(topBitmap: BitmapData, middleBitmap: BitmapData, bottomBitmap: BitmapData, layerName: String) {
        imageTop = new ImageX(topBitmap, layerName);
        imageMiddle = new ImageX(middleBitmap, layerName);
        imageBottom = new ImageX(bottomBitmap, layerName);
    }

    public function setMiddleHeight(newMiddleHeight: Int) {
        imageMiddle.setHeight(newMiddleHeight);
        recalculatePositionFromTop();
    }
    public function getMiddleHeight() return imageBottom.getY() - imageTop.getYBottom();
    public function getMiddleY() return imageMiddle.getY();
    public function getBottomY() return imageBottom.getY();
    public function getYBottom() return getY() + getHeight();
    public function setHeight(newHeight: Int) {
        lastRecalculatedHeight = newHeight;
        var newMiddleHeight = newHeight - imageTop.getHeight() - imageBottom.getHeight();
        if (newMiddleHeight <= 0)
            newMiddleHeight = 0;
        setMiddleHeight(int(newMiddleHeight));
    }

    public function recalculatePositionFromTop() {
        imageMiddle.setX(imageTop.getX());
        imageMiddle.setY(imageTop.getY() + imageTop.getHeight());
        imageBottom.setX(imageTop.getX());
        imageBottom.setY(imageMiddle.getY() + imageMiddle.getHeight());
    }

    public override function setX(newX: Float) {
        imageTop.setX(int(newX));
        recalculatePositionFromTop();
    }
    public override function setY(newY: Float) {
        imageTop.setY(int(newY));
        recalculatePositionFromTop();
    }
    public override function centerHorizontally() {
        imageTop.centerHorizontally();
        recalculatePositionFromTop();
        return this;
    }
    public override function centerVertically() {
        imageMiddle.centerVertically();
        imageTop.setY(imageMiddle.getY() - imageTop.getHeight());
        imageBottom.setY(imageMiddle.getY() + imageMiddle.getHeight());
        return this;
    }

    public override function getX(): Float return imageTop.getX();
    public override function getY(): Float return imageTop.getY();
    public override function getWidth() return imageTop.getWidth();
    public override function getHeight() return imageTop.getHeight() + imageMiddle.getHeight() + imageBottom.getHeight();
    public function hide() {
        imageTop.hide();
        imageMiddle.hide();
        imageBottom.hide();
    }
    public function show() {
        imageTop.show();
        imageMiddle.show();
        imageBottom.show();
    }

    public function growToWidthScale(value: Float, seconds: Float) {
        final middleVScale = imageMiddle.getHeight() / 10;
        imageTop.growTo(value, 1, seconds, Easing.expoOut);
        imageMiddle.growTo(value, middleVScale, seconds, Easing.expoOut);
        imageBottom.growTo(value, 1, seconds, Easing.expoOut);
    }
}
