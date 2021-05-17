

/*"
	
	Create SimpleUI's with 		new SimpleUIExtension() (once per game, see SimpleUI API)
	open(uiName)
	close(uiName)
	change(uiName)
	isOpen(uiName) : Boolean
	
"*/

import U.*;	

class GUI{
	
	public static var isReady = false;
	public static var simpleUIs 	 : Map<String, SimpleUI>;
	public static var simpleUINames  : Array<String>;	// All names of SimpleUI's
	public static var openUIs	 	 : Array<SimpleUI>;	// All open SimpleUI's

	public static inline function get(uiName) return simpleUIs[uiName];
	
	public static function init(){
		isReady = true;
		simpleUIs		= new Map<String, SimpleUI>();
		simpleUINames	= [];
		openUIs			= [];
	}
	
	public static function load(name : String){
		var ui = simpleUIs[name];
		if (ui == null) {
			throwAndLogError("ERROR: Failed to load UI with name " + name);
			return;
		}
		ui.load();
	}
	
	public static function add(s : SimpleUI){
		if(s == null){
			throwAndLogError("ERROR: Null SimpleUI given?");
			return;
		}
		simpleUIs[s.name] = s;
		simpleUINames.push(s.name);
	}
	
	public static function open(simpleUIName : String, ?metaData : Array<Dynamic>){
		simpleUIs[simpleUIName].open(metaData);
		var lastOpenedUI = getLastOpenedUI();
		if (isOpen(simpleUIName)) 
			close(simpleUIName);
		openUIs.push(simpleUIs[simpleUIName]);
	}
	
	public static function close(simpleUIName : String){
		var ui = simpleUIs[simpleUIName];
		if(ui == null) throwAndLogError("ERROR: No ui found called" + simpleUIName);
		if( ! isOpen(ui.name)) return;
		ui.close();
		openUIs.remove(ui);
	}
	
	public static function change(simpleUIName : String, ?metaData : String){
		for(ui in openUIs)
			ui.close();
		openUIs = [];
		open(simpleUIName, if(metaData == null) null else [metaData]);
	}

	public static function isOpen(simpleUIName : String){
		for(ui in openUIs)
			if(ui.name == simpleUIName)
				return true;
		return false;
	}
	
	private static function getLastOpenedUI(){
		var openUINames = openUIs.map(function(elem) return elem.name);
		if(openUINames.length > 0){
			var lastOpenedUI = simpleUIs[U.last(openUINames)];
			return lastOpenedUI;
		} else {
			return null;
		}
	}

	
}