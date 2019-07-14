

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

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;


// Instance of a spell
// Each PlayerCharacter has an array of instances of Spell
class Spell
{
	public var spellType : SpellType;
	public var level : Int = 1;
	
	
	
	public function new(s : SpellType){
		spellType = s;
	}
	
	public inline function getName(){
		return spellType.name;
	}
	
	public inline function getEffect(){
		return spellType.effect;
	}
	
	public inline function getRange(){
		return spellType.range;
	}
	
	public inline function allowSelf(){
		return spellType.allowSelf;
	}
	
	public inline function getSpecialEffectDuration(){
		return spellType.specialEffectDuration;
	}
	
	// If called as (false, null, null, func) it will skip missile
	private function sendMissileAndThen(skip : Bool, originTile : TileSpace, targetTile : TileSpace, doThis : Void -> Void){
		if(skip){
			doThis();
		} else Effects.sendMissileAndThen(originTile, targetTile, spellType.missileAnimationName, spellType.missileSpeed, function(){
			doThis();
		});
	}
	
	// If called as (false, null, null, func) it will skip effect
	private function doTargetEffectAndThen(skip : Bool, originTile : TileSpace, targetTile : TileSpace, doThis : Void -> Void){
		if(skip){
			doThis();
		} else Effects.playParticleAndThen(originTile, targetTile, this, function(){
			doThis();
		});
	}
	
	
	// Does the spell visuals
	// If it is also given an onUse function, it will also cast the spell's actual effect (as given when called)
	// Visual Order:
	//	- Missile
	//	- Spell cast (onUse)
	//	- Target Effect
	private function doVisualAndUseAndThen(originTile : TileSpace, targetTile : TileSpace, ?doSpellEffect : Void -> Void, doThis : Void -> Void){
		var skipMissile		 = !spellType.hasMissile;
		var skipTargetEffect = !spellType.hasTargetEffect;
		sendMissileAndThen(skipMissile, originTile, targetTile, function(){
			if(doSpellEffect != null) doSpellEffect();
			doTargetEffectAndThen(skipTargetEffect, originTile, targetTile, function(){
				doThis();
			});
			
		});
	}
	
	public static function castSpellAndThen(spell : Spell, caster : Unit, targetTile : TileSpace, doThis : Void -> Void){
		var onUseFunction 	: Void -> Void = null;
		//var andThenFunction : Void -> Void = null;
		switch(spell.spellType.effect){
			case SpellType.NormalMove:
				Battlefield.slideUnitToTile(caster, targetTile);
			case SpellType.SkillShot:
				var direction = getSkillShotDirection(caster, targetTile);					// Get direction
				var actualTargetTile = getSkillShotTarget(spell, caster, direction);		// Get the target tile
				if(actualTargetTile == null) {trace("Tile unavailable?"); return;};
				if(actualTargetTile.unitOnIt != null)
					onUseFunction = function(){
						spell.spellType.onUse(caster, [actualTargetTile]);
						BattlefieldUI.tryToUpdatePortraitAndBars(actualTargetTile.unitOnIt);}
				spell.doVisualAndUseAndThen(caster.tileOn, actualTargetTile, onUseFunction, doThis);
			case SpellType.AnyAlly:
				onUseFunction = function(){
					spell.spellType.onUse(caster, [targetTile]);
					BattlefieldUI.tryToUpdatePortraitAndBars(targetTile.unitOnIt);}
				spell.doVisualAndUseAndThen(caster.tileOn, targetTile, onUseFunction, doThis);
		}
	}
	
	// Directions
	public static inline var None = 0;
	public static inline var Up = 1;
	public static inline var Right = 2;
	public static inline var Left = 3;
	public static inline var Down = 4;
	
	private static function getSkillShotDirection(caster : Unit, targetTile : TileSpace){
		if(caster.getMatrixX() < targetTile.matrixX){
			return Right;
		} else if(caster.getMatrixX() > targetTile.matrixX){
			return Left;
		} else if(caster.getMatrixY() < targetTile.matrixY){
			return Down;
		} else if(caster.getMatrixY() > targetTile.matrixY){
			return Up;
		} else return None;
	}
	
	public static function getSkillShotTarget(spell : Spell, caster : Unit, direction : Int){
		var i : Int = 0;
		var iLimit : Int = 0;
		var currentTile : TileSpace = caster.tileOn;
		var remainingRange : Int = spell.getRange();
		currentTile = currentTile.getNextTileInDirection(direction);
		while(currentTile != null && remainingRange != 0){
			if(currentTile.getNextTileInDirection(direction) == null){		// If its the last tile to iterate,
				return currentTile;}										// return this tile
			if(remainingRange == 1){
				return currentTile;											// Same here
			}
			if(currentTile.unitOnIt != null){								// If this tile contains a unit,
				return currentTile;}										// return this tile
			currentTile = currentTile.getNextTileInDirection(direction);
			remainingRange--;
		}
		trace("ERROR: getSkillShotTarget returned null!");
		return null;
	}
	
}





/*			i = caster.getMatrixX() + 1;
			iLimit = Std.int( Math.min(Battlefield.nTileCols, caster.getMatrixX() + 1 + spell.getRange()) );
			while(i < iLimit){	
				i++;
			}
			case left:
				i = caster.getMatrixX() - 1;
				iLimit = Std.int ( Math.max(0, caster.getMatrixX() - 1 - spell.getRange()) );
			case up:
				i = caster.getMatrixY() - 1;
				iLimit = Std.int( Math.max(0, caster.getMatrixY() - 1 - spell.getRange()) );
			case down:
				i = caster.getMatrixY() + 1;
				iLimit = Std.int( Math.min(Battlefield.nTileRows, caster.getMatrixY() + 1 + spell.getRange()) );*/















