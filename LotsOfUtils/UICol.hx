


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
	.spacing = 10
	.float = "top" / "bottom"	// If the float is "bottom", then each child must have a "bottom" property
								// Otherwise it just acts as is the float is "top"
	
"*/

class UICol extends UIPanel
{
	
	public var float = "top";
	public var spacing = 0;
	
	public override function draw(?frame){	// Shrinks the frame every time it adds a child
		setupCoordinates(frame);
		var myFrame = getFrame();			// DEBUG: In case something doesnt work, check this out. It might change and shit
		for(i in 0...children.length){
			children[i].draw(myFrame);
			var offsetToBottom = children[i].getHeight() + spacing;
			if(float.charAt(0) == 't'){				// If float is top
				myFrame.y += offsetToBottom;
				myFrame.height += offsetToBottom;
			} else {								// If float is bottom
				myFrame.height -= offsetToBottom;
			}
		}
	}
	
	public override function setProperty(prop : String, val : String){
		var wasNormalProperty = super.setProperty(prop, val);
		if(!wasItNormalProperty){
			switch(prop){
				case "float" 	: float = val;
				case "spacing"	: spacing = Std.parseFloat(val);
				default: return false;
			}
		}
		return true;
	}
	
	
}



























