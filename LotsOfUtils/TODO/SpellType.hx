
package scripts;

import com.stencyl.Engine;

class SpellType
{
	
	// Constants
	public static inline var NoEffect = 0;
	public static inline var NormalMove = 1;
	public static inline var SkillShot = 2;
	public static inline var AnyAlly = 3;

	// Data
	public var name : String;
	public var description : String;
	
	public var effect : Int = NoEffect;
	public var specialEffectDuration : Float = 0.5;	// How mnay seconds the special effect (on hit) lasts
	
	public var hasMissile : Bool = false;
	public var missileAnimationName : String = "";
	public var missileSpeed : Float = Effects.MediumSpeed;
	
	public var hasTargetEffect : Bool = false;
	public var targetEffectAnimationName : String = "";
	
	// Specific to multiple
	public var range : Int = 0;
	
	// SkillShot specific data:
	public var SkillShot_up = false;
	public var SkillShot_left = false;
	public var SkillShot_down = false;
	public var SkillShot_right = false;
	
	// Specific to AnyAlly
	public var allowSelf = true;
	
	// The function to call for every unit it hits:
	public var use : Unit -> Array<TileSpace> -> Void;		// caster : Unit, target : Unit
	
	public function onUse(unit : Unit, tiles : Array<TileSpace>){
		if(unit == null || tiles == null || tiles == []) return;
		use(unit, tiles);
	}

	public function new(n : String, d : String){
		name = n;
		description = d;
	}
}













