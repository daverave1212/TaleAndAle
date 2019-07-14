package scripts;

import com.stencyl.Engine;

class Game
{

	public static var inventoryNRows = 6;
	public static var inventoryNCols = 10;
	

	public static var scenes = {
		No_Scene			: -1,
		Menu_Scene			: 0,
		Battlefield_Scene	: 1,
		Town_Scene 			: 2
	}
	
	public static var clickStates = {
		Waiting_For_Turn		: 1,
		Clicking_On_Spells 		: 2,
		Choosing_Spell_Target	: 3
	}
	
	public static var currentScene 		= scenes.Battlefield_Scene;
	public static var playerClickState 	= clickStates.Clicking_On_Spells;
	
	
	
	
}