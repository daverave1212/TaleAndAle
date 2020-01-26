


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
	.spacing-x = 10
	.spacing-y = 10
	
	For Children:			bottom and right properties are not allowed
		i=2  j=5
		type="template"
	
	
"*/

class UIGrid extends UIPanel
{
	
	public var childrenMatrix : Matrix<UIComponent>;
	public var spacingX : Float = 0;
	public var spacingY : Float = 0;
	
	public function new(n, nRows, nCols, ?stl){
		super(n, stl);
		childrenMatrix = new Matrix<UIComponent>(nRows, nCols);
	}
	
	public override function addChild(child : UIComponent){
		if(child == null) return;
		children.push(child);
		childrenByName[child.name] = child;
		child.parent = this;
		childrenMatrix.push(child);
		lastAddedChild = child;
	}

	public override function draw(?frame){
		setupCoordinates(frame);
		var myFrame = getFrame();			// DEBUG: In case something doesnt work, check this out. It might change and shit
		var myFrameBackup = getFrame();
		for(i in 0...childrenMatrix.nRows){
			for(j in 0...childrenMatrix.nCols){
				var child = childrenMatrix.get(i, j);
				if(child != null)
					child.draw(myFrame);
				myFrame.x += spacingX;
				myFrame.width  -= spacingX;
			}
			myFrame.x = myFrameBackup.x;
			myFrame.width = myFrameBackup.width;
			myFrame.height -= spacingY;
			myFrame.y += spacingY;			
		}
	}
	
	public override function setProperty(prop : String, val : String){
		var wasNormalProperty = super.setProperty(prop, val);
		if(!wasNormalProperty){
			var valFloat = Std.parseFloat(val);
			switch(prop){
				case "spacing-x"	: spacingX = valFloat;
				case "spacing-y"	: spacingY = valFloat;
				default: return false;
			}
		}
		return true;
	}
	
	
}
























