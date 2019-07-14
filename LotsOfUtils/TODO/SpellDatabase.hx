
package scripts;


class SpellDatabase
{
	
	public static var Generic_Attack : SpellType;
	public static var Generic_Wait : SpellType;
	public static var Generic_Move : SpellType;
	
	public static var Mage_Frostbolt : SpellType;
	public static var Mage_ManaShield : SpellType;
	public static var Mage_FireBall : SpellType;
	public static var Mage_HealingWord : SpellType;
	
	public static function loadDatabase(){
		Generic_Attack = new SpellType("Attack", "Attack the closest target");
			Generic_Attack.effect = SpellType.SkillShot;
			Generic_Attack.SkillShot_up		= true;
			Generic_Attack.SkillShot_down	= true;
			Generic_Attack.SkillShot_left	= true;
			Generic_Attack.SkillShot_right	= true;
			Generic_Attack.range = 1;
			Generic_Attack.use = function(caster : Unit, tiles : Array<TileSpace>){
				tiles[0].unitOnIt.takeDamage(3);
			}
		Generic_Move = new SpellType("Move", "Move to a close space");
			Generic_Move.effect = SpellType.NormalMove;
		Generic_Wait = new SpellType("Wait", "End your turn");
	
		Mage_Frostbolt = new SpellType("Frostbolt", "Hurls a bolt of frost in a line!");
			Mage_Frostbolt.effect = SpellType.SkillShot;
			Mage_Frostbolt.SkillShot_up		= true;
			Mage_Frostbolt.SkillShot_down	= true;
			Mage_Frostbolt.SkillShot_left	= true;
			Mage_Frostbolt.SkillShot_right	= true;
			Mage_Frostbolt.range = 3;
			Mage_Frostbolt.hasMissile = true;
			Mage_Frostbolt.missileAnimationName = "Frost Bolt";
			Mage_Frostbolt.hasTargetEffect = true;
			Mage_Frostbolt.targetEffectAnimationName = "Frost Bolt";
			Mage_Frostbolt.use = function(caster : Unit, tiles : Array<TileSpace>){
				var target = tiles[0].unitOnIt;
				tiles[0].unitOnIt.takeDamage(5);
				if(target.isDead){
					caster.say(Other.randomOf(["One down!", "Take that!"]), 1);
				}
			}
		Mage_ManaShield = new SpellType("Mana Shield", "Protects you from damage at the cost of mana.");
		Mage_FireBall = new SpellType("Fire Ball", "The target 2x2 zone explodes in fire!");
		Mage_HealingWord = new SpellType("Healing Word", "Choose an ally and heal it for a lot!");
			Mage_HealingWord.effect = SpellType.AnyAlly;
			Mage_HealingWord.use = function(caster : Unit, tiles : Array<TileSpace>){
				tiles[0].unitOnIt.heal(4);
			}
	}
	
	
	
}