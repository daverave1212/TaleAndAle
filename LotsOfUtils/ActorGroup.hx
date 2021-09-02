

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

/*
    This is a class to help position actors together
*/

class ActorGroup extends Positionable {

    public static inline var HORIZONTALLY = 0;
    public static inline var VERTICALLY = 1;

    public var actors : Array<Actor>;
    public var alignment = HORIZONTALLY;    // HORIZONTALLY or VERTICALLY
    public var paddingX = 0.0;
    public var paddingY = 0.0;

    public function new(a : Array<Actor>){
        actors = a;
    }

    public function setPaddingX(p){
        paddingX = p;
        return this;
    }

    public function setPaddingY(p){
        paddingY = p;
        return this;
    }

    public function alignHorizontally(){
        alignment = HORIZONTALLY;
        return this;
    }

    public function alignVertically(){
        alignment = VERTICALLY;
        return this;
    }

    public override function getWidth(){
        var width = 0.0;
        if(alignment == HORIZONTALLY){
            width = [for(actor in actors) actor.getWidth()].floatSum() + (actors.length - 1) * paddingX;
        } else if(alignment == VERTICALLY){
            for(actor in actors){
                if(actor.getWidth() > width){
                    width = actor.getWidth();
                }
            }
        }
        return width;
    }

    public override function getHeight(){
        var height = 0.0;
        if(alignment == HORIZONTALLY){
            for(actor in actors){
                if(actor.getHeight() > height){
                    height = actor.getHeight();
                }
            }
        } else if(alignment == VERTICALLY){
            height = [for(actor in actors) actor.getHeight()].floatSum() + (actors.length - 1) * paddingY;
        }
        return height;
    }

    public override function setX(x){
        if(actors == null  || actors.length == 0) return;
        if(alignment == HORIZONTALLY){
            actors[0].setX(x);
            for(i in 1...actors.length){
                actors[i].setX(actors[i-1].getX() + actors[i-1].getWidth() + paddingX);
                trace('Set actors[${i}] X to ${actors[i].getX()}');
            }
        } else if(alignment == VERTICALLY){
            for(a in actors){
                a.setX(x);
            }
        }
    }

    public override function setY(y){
        if(actors == null  || actors.length == 0) return;
        if(alignment == HORIZONTALLY){
            for(a in actors) a.setY(y);
        } else if(alignment == VERTICALLY){
            actors[0].setY(y);
            for(i in 1...actors.length){
                actors[i].setY(actors[i-1].getY() + actors[i-1].getHeight() + paddingY);
                trace('Set actors[${i}] Y to ${actors[i].getY()}');
            }
        }
    }

    public override function getX(){
        return if(actors.length > 0) actors[0].getX() else 0.0;
    }

    public override function getY(){
        return if(actors.length > 0) actors[0].getY() else 0.0;
    }

}

















