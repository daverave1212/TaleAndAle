

package scripts;


/*
	This is an object which holds simple npc data.
	Every shopkeeper has one, and in need, it can be created on-spot for Dialogue
*/

class NPCData
{
	
	public var name		: String;
	public var title	: String;
	public var imageName: String;

	public function new(n : String, t : String = "", i : String = ""){
		name = n;
		title = t;
		imageName = i;
	}
}