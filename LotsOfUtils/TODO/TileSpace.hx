
package scripts;


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

class TileSpace extends SceneScript
{

	public static inline var defaultWidth : Float = 45;
	public static inline var defaultHeight : Float = 27;
	
	public var tileActor : Actor;
	public var matrixX : Int = 0;
	public var matrixY : Int = 0;
	public var unitOnIt : Unit = null;

	public function new(realx : Float, realy : Float){
		super();
		tileActor = createRecycledActorOnLayer(ActorTypes.tile(), realx, realy, 1, "Tiles");
		addMouseOverActorListener(tileActor, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(3 == mouseState){
				onClick();}
			if(1 == mouseState){
				onEnter();}
			if(-1 == mouseState){
				onExit();}
		});
	}
	
	private function onClick(){
		//trace("Clicked on " + matrixY + "," + matrixX);
		Battlefield.onClickOnTile(this);
	}
	
	private function onEnter(){
		//tileActor.setAnimation("Yellow");
	}
	
	private function onExit(){
		//tileActor.setAnimation("Normal");
	}
	
	public function highlight(){
		tileActor.setAnimation("Yellow");
	}
	
	public function unhighlight(){
		tileActor.setAnimation("Normal");
	}
	
	public function getAboveTile(){
		trace("Getting above tile");
		if(matrixY == 0){
			return null;
		} else {
			return Battlefield.tiles.get(matrixY - 1, matrixX);
		}
	}
	
	public function getBelowTile(){
		trace("Getting below tile");
		if(matrixY == Battlefield.nTileRows - 1){
			return null;
		} else {
			return Battlefield.tiles.get(matrixY + 1, matrixX);
		}
	}
	
	public function getNextTile(){
		trace("Getting next tile");
		if(matrixX == Battlefield.nTileCols - 1){
			return null;
		} else {
			return Battlefield.tiles.get(matrixY, matrixX + 1);
		}
	}
	
	public function getPrevTile(){
		trace("Getting prev tile");
		if(matrixX == 0){
			return null;
		} else {
			return Battlefield.tiles.get(matrixY, matrixX - 1);
		}
	}
	
	public function getNextTileInDirection(direction : Int){
		switch(direction){
			case Spell.Right: 	return getNextTile();
			case Spell.Left:  	return getPrevTile();
			case Spell.Up:		return getAboveTile();
			case Spell.Down:	return getBelowTile();
			default: return null;
		}
	}
	
	public function hasUnit(){
		if(unitOnIt != null) return true;
		return false;
	}
	
}








