
package scripts;

import com.stencyl.Engine;


// The template for an enemy
// Units can be created from enemy
// And there's a database of Enemies
class Enemy
{
	public var name = "Wolf";
	public var stats : Stats;
	public var level : Int = 1;
	
	public var spells : Array<SpellType>;	// Each enemy has up to 5 spells
	
	public function new(n : String){
		name = n;
		stats = new Stats();
		spells = new Array<SpellType>();
	}
	
	public function createSpellArray(){
		var a = new Array<Spell>();
		for(i in 0...spells.length){
			a.push(new Spell(spells[i]));
		}
		return a;
	}

}