

package scripts;

import com.stencyl.Engine;


// A set of data for a character the player has
class PlayerCharacter
{

	public var name : String = "Johnny"; 					// Name of the character
	public var characterClass : CharacterClass = null;		// Reference to a class from ClassDatabase
	public var level : Int = 1;								// The current level of the character
	
	public var availableSpells : Array<Spell>;				// The 10 spells available, they are instances
	public var readySpells : Array<Spell>;					// The 5 spells ready, they are references to spells in availableSpells
	
	public var stats : Stats;								// Total stats of the character
	
	public function new(n : String, c : CharacterClass){
		name = n;
		characterClass = c;
		stats = new Stats(c.stats);
		availableSpells = characterClass.createSpellArray();
		readySpells = [null, null, null, null, null];
		/*DEBUG*/ readyAllSpells();
	}
	
	public /*DEBUG*/ function readyAllSpells(){
		for(i in 0...availableSpells.length){
			readySpells[i] = availableSpells[i];
		}
	}
	
	
	
}



















