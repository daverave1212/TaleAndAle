
package scripts;

import com.stencyl.Engine;

	//armor           : 0 to 10
	//speed           : 0 to 1
	//critChance      : 0 to 5
	//initiative      : 0 to 5
	//maxHealth       : 0 to 7
	//maxMana         : 0 to 7
	//attackPower     : 0 to 10
	//spellPower      : 0 to 10
	
	
class ItemSuffixes{
	public static inline var Of_Tiger	    = 1;
	public static inline var Of_Bear		= 2;
	public static inline var Of_Eagle	    = 3;		// Thes are used to reference an item suffix
	public static inline var Of_Owl			= 4;
	public static inline var Of_Wolf		= 5;
	public static inline var Of_Eunuch	    = 6;
	public static inline var Of_Zgripsor	= 7;
	public static inline var Of_Fatness		= 8;
	
	public static var tiger    : Stats;
	public static var bear     : Stats;
	public static var eagle    : Stats;
	public static var owl      : Stats;					// Stats respective to each item suffix
	public static var wolf     : Stats;
	public static var eunuch   : Stats;
	public static var zgripsor : Stats;
	public static var fatness  : Stats;
	
	public static function init(){	//ARM	SPD		CRIT	INIT	HP		MANA	ATK		SP
		tiger     = 	Stats.create(0,		0,		5,		0,		0,		0,		10,		0);
		bear      = 	Stats.create(10,	0,		0,		0,		10,		0,		0,		0);
		eagle     = 	Stats.create(0,		0,		4,		0,		0,		8,		0,		0);
		owl       = 	Stats.create(0,		0,		0,		4,		0,		0,		0,		10);
		wolf      = 	Stats.create(0,		1,		0,		5,		0,		0,		10,		0);
		eunuch    = 	Stats.create(5,		0,		0,		0,		0,		10,		0,		10);
		zgripsor  = 	Stats.create(5,		1,		0,		3,		0,		0,		0,		0);
		fatness   = 	Stats.create(10,	0,		0,		0,		12,		0,		0,		0);
	}
	
	public static function getRandomSuffix(){
		return Std.random(8) + 1;
	}
	
	// Takes a suffix (inline Int from above) and returns a new instance of its respective stats
	public static function getStatsBySuffix(suffix : Int){
		switch(suffix){
			case Of_Tiger		: return new Stats(tiger)     ;
			case Of_Bear    	: return new Stats(bear)      ;
			case Of_Eagle   	: return new Stats(eagle)     ;
			case Of_Owl     	: return new Stats(owl)       ;
			case Of_Wolf    	: return new Stats(wolf)      ;
			case Of_Eunuch  	: return new Stats(eunuch)    ;
			case Of_Zgripsor	: return new Stats(zgripsor)  ;
			case Of_Fatness 	: return new Stats(fatness)   ;
		}
		return null;
	}
	
	public static function getSuffixAsString(suffix : Int){
		switch(suffix){
			case Of_Tiger	     : return "of the " + "Tiger";
			case Of_Bear         : return "of the " + "Bear";
			case Of_Eagle        : return "of the " + "Eagle";
			case Of_Owl          : return "of the " + "Owl";
			case Of_Wolf         : return "of the " + "Wolf";
			case Of_Eunuch       : return "of the " + "Eunuch";
			case Of_Zgripsor     : return "of the " + "Zgripsor";
			case Of_Fatness      : return "of the " + "Fatness";
		}
		return "Error at suffix";
	}
	
	
}


// OK SO, ITEMS DONT SCALE, BECAUSE ITS MORE SATISFYING TO GET COOL PREMADE ITEMS IN SHOP
// BUT WE ALSO HAVE RANDOMLY GENERATED ITEMS (of the wolf n shit)

// It's not static so I can access it as ItemDatabase.rarities.Rare_Items
class ItemRarities{
	public var Trash_Item		= 0;
	public var Common_Item		= 1;
	public var Rare_Item			= 2;
	public var Epic_Item			= 3;
	public var Legendary_Item	= 4;
	public function new(){}}
class ItemSlots{
	public var No_Slot       = 0;
	public var Head_Slot     = 1;
	public var Body_Slot     = 2;
	public var Trinket_Slot  = 3;
	public var Weapon_Slot   = 4;
	public function new(){}
	
	// Returns either Body_Slot or Head_Slot
	public function getRandomArmorSlot(){
		return Std.random(2) + 1;
	}
	
}

/*
	I make a giant JSON of random items
	I sort them by : Level > Slot


	Clickable items are images, loaded when needed.
	
*/


class ItemDatabase
{
	
	public static var rarities	: ItemRarities;
	public static var slots		: ItemSlots;
	public static var items		: Array<Item>;

	public static function init(){
		items = [];
		// All items:
		items.push(Item.create('Potion of Swiftness', 'PotionGreen', 0, 1, 150, Stats.create(0, 0, 0, 0, 0, 0, 0, 0)));
		items.push(Item.create('Potion of Rage', 'PotionRed', 0, 1, 150, Stats.create(0, 0, 0, 0, 0, 0, 0, 0)));
		items.push(Item.create('Potion of Health', 'PotionRed', 0, 1, 150, Stats.create(0, 0, 0, 0, 0, 0, 0, 0)));
			items[items.length - 1].isStackable = true;
			items[items.length - 1].nStacks = 3;
			items[items.length - 1].onUse = function(caster : Unit){
				trace("Used a potion of health!");
			};
			items[items.length - 1].onUseDescription = "Restores 5 health when used.";
		items.push(Item.create('Potion of Mana', 'PotionBlue', 0, 1, 150, Stats.create(0, 0, 0, 0, 0, 0, 0, 0)));
		items.push(Item.create('Goth Headband', 'Headband', 1, 1, 125, Stats.create(2, 0, 0, 0, 0, 0, 0, 0)));
		items.push(Item.create('Bandit Mask', 'Mask', 1, 1, 285, Stats.create(1, 0, 0, 0, 1, 0, 0, 0)));
		items.push(Item.create('Rags', 'Rags', 2, 0, 50, Stats.create(1, 0, 0, 0, 0, 0, 0, 0)));
		items.push(Item.create('Squirrel Fur Rags', 'Rags', 2, 0, 72, Stats.create(1, 0, 5, 0, 0, 0, 0, 0)));
		items.push(Item.create('Paladin Helmet', 'Helmet', 1, 2, 850, Stats.create(7, 0, 38, 12, 0, 0, 0, 17)));


		 
		
	}
	
	//public static function getRandomizedArmor(level : Int){
	//	var item = new Item();
	//	var itemSlot = ItemSlots.getRandomArmorSlot();
	//	var itemSlotName = ItemSlots.getArmorNameBySlotAndLevel(itemSlot, level);
	//	var itemSuffix = ItemSuffixes.getRandomSuffix();
	//	var itemSuffixStats = ItemSuffixes.getStatsBySuffix(itemSuffix);
	//	item.name = itemSlotName + " " + ItemSuffixes.getSuffixAsString(itemSuffix);
	//	item.slot = itemSlot;
	//	item.imageName = itemSlotName;
	//	item.stats = itemSuffixStats;
	//	item.stats.times(1 + (level) / 4);
	//	return item;
	//	
	//}
	//
	//public static function createGeneratedArmorItem(slot : Int, suffix : Int, level : Int){
	//	var item = new Item();
	//	var itemSuffixStats = ItemSuffixes.getStatsBySuffix(suffix);
	//	item.type = type;
	//	item.rarity = rarity;
	//}
	
	public static function loadDatabase(){
		ItemSuffixes.init();
		rarities = new ItemRarities();
		slots = new ItemSlots();
		init();
	}
}