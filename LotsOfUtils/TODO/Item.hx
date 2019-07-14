

package scripts;

import com.stencyl.Engine;

class Item
{

	
	public var name : String = "noname";
	public var level : Int = 1;
	public var slot : Int = 0;
	public var rarity : Int = 1;
	public var stats : Stats;
	public var imageName : String;
	public var price : Int = 0;
	public var onUse : Unit -> Void = null;
	public var onUseDescription : String = "";	// Appears in the item description
	public var isStackable = false;
	public var nStacks = 0;

	public function new(){}
	
	// Consumes 1 charge from the item.
	// If charges become less than 0, removes the item
	public static function consumeItem(item : Item, parentInventory : Inventory<Item>){
		var coordinates : Vector2Int = parentInventory.find(item);
		if(coordinates == null) return;
		if(item.isStackable){
			item.nStacks--;
			if(item.nStacks == 0){
				parentInventory.remove(coordinates.y, coordinates.x);
			}
		}
		else {
			parentInventory.remove(coordinates.y, coordinates.x);
		}
	}
	
	public static function generateDescription(item : Item){
		var desc = "";
		var s = item.stats;
		if(s.armor != 0){ desc += "+ " + s.armor + " Armor \n "; }
		if(s.maxHealth != 0){ desc += "+ " + s.maxHealth + " Health \n "; }
		if(s.maxMana != 0){ desc += "+ " + s.maxMana + " Mana \n "; }
		if(s.critChance != 0){ desc += "+ " + s.critChance + " Crit \n "; }
		if(s.speed != 0){ desc += "+ " + s.speed + " Speed \n "; }
		if(s.initiative != 0){ desc += "+ " + s.initiative + " Initiative \n "; }
		if(s.attackPower != 0){ desc += "+ " + s.attackPower + " Attack Power \n "; }
		if(s.spellPower != 0){ desc += "+ " + s.spellPower + " Spell Power \n "; }
		if(item.onUseDescription != ""){ desc += item.onUseDescription + " \n ";}
		trace(desc);
		return desc;
	}
	
	public static function create(name : String, imgname : String, slot : Int, rarity : Int, price : Int, stats : Stats){
		var item = new Item();
		item.name = name;
		item.imageName = imgname;
		item.slot = slot;
		item.rarity = rarity;
		item.stats = new Stats(stats);
		item.price = price;
		return item;
	}
	
	
}