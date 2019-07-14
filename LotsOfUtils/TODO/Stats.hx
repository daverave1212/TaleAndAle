
package scripts;


// A Stats object represents a collection of stats
// Items, monsters, classes etc have stats

class Stats
{
	
	public var armor : Float = 0;			// 13 is base
	public var speed : Int = 0;
	public var critChance : Float = 0;
	public var initiative : Float = 0;
	public var maxHealth : Float = 0;
	public var maxMana : Float = 0;
	public var attackPower : Float = 0;
	public var spellPower : Float = 0;
	
	public static function create(armor : Float, speed : Int, critChance : Float, initiative : Float, maxHealth : Float, maxMana : Float, attackPower : Float, spellPower : Float){
		var ret = new Stats();
		ret.armor         = armor        ;
		ret.speed         = speed        ;
		ret.critChance    = critChance   ;
		ret.initiative    = initiative   ;
		ret.maxHealth 	  = maxHealth    ;
		ret.maxMana   	  = maxMana      ;
		ret.attackPower	  = attackPower;
		ret.spellPower 	  = spellPower;
		return ret;
	}
	
	public function new(?s : Stats){
		if(s != null){
			copy(s);
		}
	}
	
	public function copy(s : Stats){
		armor         = s.armor        ;
		speed         = s.speed        ;
	    critChance    = s.critChance   ;
	    initiative    = s.initiative   ;
		maxHealth 	  = s.maxHealth    ;
        maxMana   	  = s.maxMana      ;
        attackPower	  = s.attackPower;
        spellPower 	  = s.spellPower;
	}
	
	public function add(s : Stats){
		armor         += s.armor        ;
		speed         += s.speed        ;
	    critChance    += s.critChance   ;
	    initiative    += s.initiative   ;
		maxHealth 	  += s.maxHealth    ;
        maxMana   	  += s.maxMana      ;
        attackPower	  += s.attackPower;
        spellPower 	  += s.spellPower;
	}
	
	public function subtract(s : Stats){
		armor         -= s.armor        ;
		speed         -= s.speed        ;
	    critChance    -= s.critChance   ;
	    initiative    -= s.initiative   ;
		maxHealth 	  -= s.maxHealth	;
        maxMana   	  -= s.maxMana  	;
        attackPower	  -= s.attackPower;
        spellPower 	  -= s.spellPower;
	}
	
	public function print(){
		trace("armor       " +  armor            );
		trace("speed       " +  speed            );
		trace("critChance  " +  critChance       );
		trace("initiative  " +  initiative       );
		trace("maxHealth   " +   maxHealth 	     );
		trace("maxMana     " +   maxMana   	     );
		trace("attackPower " +    attackPower	 ); 
		trace("spellPower  " +   spellPower 	 ); 
		
	}
	
	public function times(k : Int){
		armor         *= k;
		speed         *= k;
	    critChance    *= k;
	    initiative    *= k;
		maxHealth 	  *= k;
        maxMana   	  *= k;
        attackPower	  *= k;
        spellPower 	  *= k;
	}
	
	public function clear(){
		armor         = 0;
		speed         = 0;
	    critChance    = 0;
	    initiative    = 0;
		maxHealth	  = 0;
        maxMana  	  = 0;
        attackPower	  = 0;
        spellPower 	  = 0;
	}
	
	
}