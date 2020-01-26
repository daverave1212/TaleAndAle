
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
import box2D.collision.shapes.B2Shape;

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
	--- REQUIRES ImageX.hx
	
	API:
	
*/

class Style
{


	/*
	x
	y
	top
	left
	bottom
	right
	width
	height
	
	
	*/
	
	private static function _stringContains(s : String, letter : String){
		for(i in 0...s.length){
			if(s.charAt(i) == letter){
				return s.charAt(i);
			}
		}
		return "";
	}
	
	private static function _splitString(s : String, delimiters : String){
		var start = 0;
		var end = 0;
		var returnedArray : Array<String> = new Array<String>();
		var lastLetterWasDelimiter = false;
		for(i in 0...s.length){
			var letter = s.charAt(i);
			if(_stringContains(delimiters, letter) != ""){
				if(lastLetterWasDelimiter){
					start = i + 1;
				} else {
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
		if(!lastLetterWasDelimiter){
            returnedArray.push(s.substring(start));
        }
		return returnedArray;
	}
	
	public static function setPercentLeftInScene(?a : Actor, ?img : ImageX, x : Float){
		if(a == null) return;
		var newx = x / 100 * getSceneWidth();
		a.setX(newx);
	}
	

	public static function setXCenter(?a : Actor, ?img : ImageX, x : Float){
		
		if(a == null) return;
		a.setX(x - a.getWidth() / 2);
	}

	public static function setYCenter(?a : Actor, ?img : ImageX, y : Float){
	
		if(a == null) return;
		a.setY(y - a.getHeight() / 2);
	}

	public static function center(?a : Actor, ?img : ImageX){
		if(img != null){
			setMidTop(img, 0);
			setMidRight(img, 0);
		}
		if(a == null) return;
		setMidTop(a, 0);
		setMidRight(a, 0);
		a.unanchorFromScreen();
	}
	
	public static inline function style(?a : Actor, ?img : ImageX, s : String){
		setStyle(a, s);
	}
	
	public static function setStyle(?a : Actor, ?img : ImageX, s : String){
		var style = _splitString(s, " :;\n");
		//trace("Got style as: " + style);
		var property : String = "";
		var value : String = "";
		var dontAnchor = false;

		for(i in 0...style.length){
			if(i%2 == 0){
				property = style[i];
				continue;
			} else {
				value = style[i];
				//trace("At " + value + ": last char is " + value.charAt(value.length - 1));
				// Style below:
				switch(property){
					case "x": a.setX(Std.parseInt(value));
					case "y": a.setY(Std.parseInt(value));
					case "anchor":
						if(value == "no"){
							dontAnchor = true;
						}
					case "top":
						if(value.charAt(value.length - 1) == "%")
							setPercentTop(a, Std.parseFloat(value));
						else
							setTop(a, Std.parseFloat(value));
					case "bottom":
						if(value.charAt(value.length - 1) == "%")
							setPercentBottom(a, Std.parseFloat(value));
						else
							setBottom(a, Std.parseFloat(value));
					case "left":
						if(value.charAt(value.length - 1) == "%")
							setPercentLeft(a, Std.parseFloat(value));
						else
							setLeft(a, Std.parseFloat(value));
					case "right":
						if(value.charAt(value.length - 1) == "%")
							setPercentRight(a, Std.parseFloat(value));
						else
							setRight(a, Std.parseFloat(value));
					case "width":
						if(value.charAt(value.length - 1) == "%")
							setWidthPercent(a, Std.parseFloat(value));
						else
							setWidth(a, Std.parseFloat(value));
					case "height":
						if(value.charAt(value.length - 1) == "%")
							setHeightPercent(a, Std.parseFloat(value));
						else
							setHeight(a, Std.parseFloat(value));
					case "mid-top":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidTop(a, Std.parseFloat(value));
						else
							setMidTop(a, Std.parseFloat(value));
					case "mid-bottom":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidBottom(a, Std.parseFloat(value));
						else
							setMidBottom(a, Std.parseFloat(value));
					case "mid-left":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidLeft(a, Std.parseFloat(value));
						else
							setMidLeft(a, Std.parseFloat(value));		
					case "mid-right":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidRight(a, Std.parseFloat(value));
						else
							setMidRight(a, Std.parseFloat(value));		
							
							
				}
			}
		}
		a.unanchorFromScreen();
	}

	// Pixel single dimensions
	public static function setWidth(?a : Actor, ?img : ImageX, w : Float){
		var newPercent = w / a.getWidth();
		trace("Got new percent as " + newPercent);
		a.growTo(newPercent, 1, 0, Easing.linear);
	}

	public static function setHeight(?a : Actor, ?img : ImageX, h : Float){
		var newPercent = h / a.getHeight();
		trace("Got new percent as " + newPercent);
		a.growTo(1, h, 0, Easing.linear);
		
	}
	
	// Percent single dimensions
	public static function setWidthPercent(?a : Actor, ?img : ImageX, w : Float){
		a.growTo((w * getScreenWidth() / 100) / a.getWidth(), 1, 0, Easing.linear);
	}

	public static function setHeightPercent(?a : Actor, ?img : ImageX, h : Float){
		a.growTo(1, (h * getScreenHeight() / 100) / a.getHeight(), 0, Easing.linear);
	}


	// Pixel single position
	public static function top(t, ?uselessParam) return getScreenY() + t;
	public static function setTop(?a : Actor, ?img : ImageX, top : Float){
		if(img != null){
			img.setY(getScreenY() + top);
		} else if(a == null) return;
		a.setY(getScreenY() + top);
		a.anchorToScreen();
	}
	
	public static function bottom(b, height) return getScreenY() + getScreenHeight() - height - b;
	public static function setBottom(?a : Actor, ?img : ImageX, bottom : Float){
		if(img != null){
			img.setY(getScreenY() + getScreenHeight() - img.getHeight() - bottom);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.anchorToScreen();
	}
	
	public static function left(l, ?uselessParam) return getScreenX() + l;
	public static function setLeft(?a : Actor, ?img : ImageX, left : Float){
		if(img != null){
			img.setX(getScreenX() + left);
		} else if(a == null) return;
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}
	
	public static function right(r, width) return getScreenX() + getScreenWidth() - width - r;
	public static function setRight(?a : Actor, ?img : ImageX, right : Float){
		if(img != null){
			img.setX(getScreenX() + getScreenWidth() - img.getWidth() - right);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	public static function midTop(t, height) return getScreenY() + getScreenHeight()/2 - height/2 - t;
	public static function setMidTop(?a : Actor, ?img : ImageX, top : Float){
		if(img != null){
			getScreenY();
			getScreenHeight();
			img.setY(getScreenY() + getScreenHeight()/2 - img.getHeight()/2 - top);
		}
		if(a == null){
			trace("a null. returning");
			return;
		}
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 - top);
		a.anchorToScreen();
	}
	
	public static function midBottom(b, height) return getScreenY() + getScreenHeight()/2 - height/2 + b;
	public static function setMidBottom(?a : Actor, ?img : ImageX, bottom : Float){
		if(img != null){
			img.setY(getScreenY() + getScreenHeight()/2 - img.getHeight()/2 + bottom);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 + bottom);
		a.anchorToScreen();
	}
	
	public static function midLeft(l, width) return getScreenX() + getScreenWidth()/2 - width/2 - l;
	public static function setMidLeft(?a : Actor, ?img : ImageX, left : Float){
		if(img != null){
			img.setX(getScreenX() + getScreenWidth()/2 - img.getWidth()/2 - left);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 - left);
		a.anchorToScreen();
	}
	
	public static function midRight(r, width) return getScreenX() + getScreenWidth()/2 - width/2 + r;
	public static function setMidRight(?a : Actor, ?img : ImageX, right : Float){
		if(img != null){
			img.setX(getScreenX() + getScreenWidth()/2 - img.getWidth()/2 + right);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 + right);
		a.anchorToScreen();
	}
	


	// Percent single position
	public static function percentMidTop(t, height){
		var perc = getScreenHeight() * (t / 100);
		return getScreenY() + getScreenHeight()/2 - height/2 - perc;
	}
	public static function setPercentMidTop(?a : Actor, ?img : ImageX, top : Float){
		var perc = getScreenHeight() * (top / 100);
		if(img != null){
			img.setY(getScreenY() + getScreenHeight()/2 - img.getHeight()/2 - perc);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 - perc);
		a.anchorToScreen();
	}
	
	public static function percentMidLeft(l, width){
		var perc = getScreenWidth() * (l / 100);
		return getScreenX() + getScreenWidth()/2 - width/2 - perc;
	}
	public static function setPercentMidLeft(?a : Actor, ?img : ImageX, left : Float){
		var perc = getScreenWidth() * (left / 100);
		if(img != null){
			img.setX(getScreenX() + getScreenWidth()/2 - img.getWidth()/2 - perc);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 - perc);
		a.anchorToScreen();
	}
	
	public static function percentMidBottom(b, height){
		var perc = getScreenHeight() * (b / 100);
		return getScreenY() + getScreenHeight()/2 - height/2 + perc;
	}
	public static function setPercentMidBottom(?a : Actor, ?img : ImageX, top : Float){
		var perc = getScreenHeight() * (top / 100);
		if(img != null){
			img.setY(getScreenY() + getScreenHeight()/2 - img.getHeight()/2 + perc);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 + perc);
		a.anchorToScreen();
	}
	
	public static function percentMidRight(r, width){
		var perc = getScreenWidth() * (left / 100);
		return getScreenX() + getScreenWidth()/2 - width/2 + perc;
	}
	public static function setPercentMidRight(?a : Actor, ?img : ImageX, left : Float){
		var perc = getScreenWidth() * (left / 100);
		if(img != null){
			img.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 + perc);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 + perc);
		a.anchorToScreen();
	}
	
	public static function percentTop(t, ?uselessParam){
		var perc = getScreenHeight() * (t / 100);
		return getScreenY() + perc;
	}
	public static function setPercentTop(?a : Actor, ?img : ImageX, top : Float){
		var perc = getScreenHeight() * (top / 100);
		if(img != null){
			img.setY(getScreenY() + perc);
		} else if(a == null) return;
		a.setY(getScreenY() + perc);
		a.anchorToScreen();
	}
	
	public static function percentBottom(b, height){
		var perc = getScreenHeight() * (b / 100);
		return getScreenY() + getScreenHeight() - height() - perc;
	}
	public static function setPercentBottom(?a : Actor, ?img : ImageX, bottom : Float){
		var perc = getScreenHeight() * (bottom / 100);
		if(img != null){
			img.setY(getScreenY() + getScreenHeight() - img.getHeight() - perc);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - perc);
		a.anchorToScreen();
	}
	
	public static function percentLeft(l, ?uselessParam){
		var perc = getScreenWidth() * (l / 100);
		return getScreenX() + perc
	}
	public static function setPercentLeft(?a : Actor, ?img : ImageX, left : Float){
		var perc = getScreenWidth() * (left / 100);
		if(img != null){
			img.setX(getScreenX() + perc);
		} else if(a == null) return;
		a.setX(getScreenX() + perc);
		a.anchorToScreen();
	}
	
	public static function percentRight(r, width){
		var perc = getScreenWidth() * (r / 100);
		return getScreenX() + getScreenWidth() - width - perc
	}
	public static function setPercentRight(?a : Actor, ?img : ImageX, right : Float){
		var perc = getScreenWidth() * (right / 100);
		if(img != null){
			img.setX(getScreenX() + getScreenWidth() - img.getWidth() - perc);
		} else if(a == null) return;
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - perc);
		a.anchorToScreen();
	}
	
	
	// Pixel double position
	public static function setTopLeft(?a : Actor, ?img : ImageX, top : Float, left : Float){
		if(img != null){
			setTop(img, top);
			setLeft(img, left);
		} else if(a == null) return;
		a.setY(getScreenY() + top);
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}
	
	public static function setTopRight(?a : Actor, ?img : ImageX, top : Float, right : Float){
		if(img != null){
			setTop(img, top);
			setRight(img, right);
		} else if(a == null) return;
		a.setY(getScreenY() + top);
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	public static function setBottomLeft(?a : Actor, ?img : ImageX, bottom : Float, left : Float){
		if(img != null){
			setBottom(img, bottom);
			setLeft(img, left);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}

	public static function setBottomRight(?a : Actor, ?img : ImageX, bottom : Float, right : Float){
		if(img != null){
			setBottom(img, bottom);
			setRight(img, right);
		} else if(a == null) return;
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	// Percent double position
	
	public static function setPercentTopLeft(?a : Actor, ?img : ImageX, top : Float, left : Float){
		if(img != null){
			setPercentTop(img, top);
			setPercentLeft(img, left);
		} else if(a == null) return;
		setPercentTop(a, top);
		setPercentLeft(a, left);
	}
	
	public static function setPercentTopRight(?a : Actor, ?img : ImageX, top : Float, right : Float){
		if(img != null){
			setPercentTop(img, top);
			setPercentRight(img, right);	
		} else if(a == null) return;
		setPercentTop(a, top);
		setPercentRight(a, right);
	}
	
	public static function setPercentBottomRight(?a : Actor, ?img : ImageX, bottom : Float, right : Float){
		if(img != null){
			setPercentBottom(img, bottom);
			setPercentRight(img, right);
		} else if(a == null) return;
		setPercentBottom(a, bottom);
		setPercentRight(a, right);
	}
	
	public static function setPercentBottomLeft(?a : Actor, ?img : ImageX, bottom : Float, left : Float){
		if(img != null){
			setPercentBottom(img, bottom);
			setPercentLeft(img, left);
		} else if(a == null) return;
		setPercentBottom(a, bottom);
		setPercentLeft(a, left);
	}
	
	
	// Other Functions
	
	public static function sendOnTop(?a : Actor, ?img : ImageX){
		if(img != null){
			bringImagetoFront(img.image);
		} else if(a == null) return;
		a.anchorToScreen();
	}

	public function new(){
		
	}

}