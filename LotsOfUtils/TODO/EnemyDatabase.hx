
package scripts;

import com.stencyl.Engine;

class EnemyDatabase
{
	
	public static var peasant : Enemy;
	
	public static function loadDatabase(){
		peasant = new Enemy("Peasant");
			peasant.stats.maxHealth = 10;
			peasant.stats.speed = 2;
			peasant.spells.push(SpellDatabase.Generic_Attack);
		trace("  Loaded enemy database");
	}
	
	
}