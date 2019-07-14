/*
    Stencyl exclusively uses the Haxe programming language. 
    Haxe is similar to ActionScript and JavaScript.
    
    Want to use native code or make something reusable? Use the Extensions Framework instead.
    http://www.stencyl.com/help/view/engine-extensions/
    
    Learn more about Haxe and our APIs
    http://www.stencyl.com/help/view/haxe/
*/

package scripts;

import com.stencyl.Engine;

class TODO
{	/*
	 *	Font I use:
	 *	Damage: VCR_OSD_MONO_1.001
	 *
	 *
	 */

	
	/*
	 * o A JS parser for the SpellDatabase
	 * o A basic AI system (ex: if moveSpeed > 0 find a place to move, then cast a random spell)
	 * o Remake the button system and refactor
	 * 
	 * Noteaza-ti pe o foaie exact ce functii de initializare sunt
	 *   si fa un Q&A cu chestiile esentiale, explicate in cuvinte
	 *  
	 * Also, do that Q&A!!!  
	 *   
	 * o Finish the Spell.cast(spell, caster, tile)
	 * o Add more spell types (like line) with indicators
	 * o Make a turn system
	 */
	 
	 
	/*
	Once per game:
		Player.init()						- which contains
			ClassDatabase.loadDatabase()
			EnemyDatabase.loadDatabase()
			SpellDatabase.loadDatabase()
		Sayer.init()
		
	On Battlefield scene:
		Battlefield.start() - which contains
			Battlefield.spawnTiles()
			Battlefield.spawnUnitsOnBattlefield()
			UserInterface.drawSpellButtons()

	Once on each scene:
		UserInterface.start()		- creates a new Script so i acn attack listeners and shit
	*/
}







