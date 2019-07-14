

/*"
	
	Create SimpleUI's with 		new SimpleUIExtension() (once per game, see SimpleUI API)
	open(uiName)
	close(uiName)
	change(uiName)
	
"*/
	

class SimpleUIManager{
	
	public static var isReady = false;
	public static var simpleUIs : Map<String, SimpleUI>;
	public static var simpleUINames  : Array<String>;	// All names of SimpleUI's
	public static var openUIs	 	 : Array<SimpleUI>;	// All open SimpleUI's

	public static inline function get(uiName) return simpleUIs[uiName];
	
	public static function init(){
		isReady = true;
		simpleUIs		= new Map<String, SimpleUI>();
		simpleUINames	= [];
		openUIs			= [];
	}
	
	public static function get(name : String){
		return simpleUIs[name];
	}
	
	public static function add(s : SimpleUI){
		if(s == null){
			trace("ERROR: Null SimpleUI given?");
			return;
		}
		simpleUIs[s.name] = s;
		simpleUINames.push(s.name);
	}
	
	public static function open(simpleUIName : String, ?metaData : Array<Dynamic>){
		simpleUIs[simpleUIName].open(metaData);
		simpleUIs[simpleUIName].isOpen = true;
		simpleUIs[simpleUIName].isFocused = true;
		lastOpenedUI = getLastOpenedUI();
		if(lastOpenedUI != null){
			lastOpenedUI.isFocused = false;
		}
		openUIs.push(simpleUIs[simpleUIName]);
	}
	
	public static function close(simpleUIName : Array<Dynamic>){
		var ui = simpleUIs[simpleUIName];
		if(ui.isFocused){
			ui.isFocused = false;
			openUIs.pop();
			lastOpenedUI = getLastOpenedUI();
			if(lastOpenedUI != null){
				lastOpenedUI.isFocused = true;
			}
		} else {
			openUIs.remove(ui);
		}
	}
	
	public static function change(simpleUIName : String, ?metaData : String){
		for(ui in openUIs)
			ui.close();
		openUIs = [];
		open(simpleUIName, metaData);
	}
	
	private static function getLastOpenedUI(){
		if(openUINames.length > 0){
			var lastOpenedUI = simpleUIs[U.last(openUINames)];
			return lastOpenedUI;
		} else {
			return null;
		}
	}
	
}