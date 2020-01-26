 
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

import com.stencyl.utils.motion.*;
import scripts.Other.*;

class ShopKeeper
{
	public var actor : Actor;
	public var inventory : Inventory<Item>;
	public var npcData	: NPCData;
	public var index : Int = 0;
	
	public function new(name : String, title : String){
		actor = createActor(ActorTypes.shopKeeper(), "ShopKeepers");
		npcData = new NPCData(name, title, "ui/" + name + ".png");		// That path is only used for dialogues
		actor.setAnimation(name);
		actor.setX(100);
		actor.setY(50);
		inventory = new Inventory<Item>(Game.inventoryNRows, Game.inventoryNCols);
		UserInterface.ui.addMouseOverActorListener(actor, function(mouseState:Int, list:Array<Dynamic>):Void{
			if(5 == mouseState){
				onClick();
			}
		});
	}
	
	public function onClick(){
		Town.onClickOnShopKeeper(this);
	}
	
	public function talk(){
		trace("So trying to talk...");
		Dialogue.prompt(npcData, "No dialogue attached to this NPC.",
			"say wot",
			"wot fml",
			function(){TownUI.isAnyTownUIOpen = false; Dialogue.close();},
			function(){TownUI.isAnyTownUIOpen = false; Dialogue.close();});
	}
	
	
	
}













