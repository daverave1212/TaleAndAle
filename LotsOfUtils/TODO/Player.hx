
package scripts;

import com.stencyl.Engine;

// Static class, containing everything about the player
class Player
{
	public static var playerCharacters : Array<PlayerCharacter>;
	
	public static var inventory : Inventory<Item>;
	
	public static function init(){
		SpellDatabase.loadDatabase();
		ClassDatabase.loadDatabase();
		EnemyDatabase.loadDatabase();
		ItemDatabase.loadDatabase();

		inventory = new Inventory(Game.inventoryNRows, Game.inventoryNCols);	// 6 rows, 10 columns
	
		playerCharacters = new Array<PlayerCharacter>();
		playerCharacters.push(new PlayerCharacter("Tiara", ClassDatabase.mage));

		// DEBUG
		inventory.addArray(ItemDatabase.items);
	}
	
}