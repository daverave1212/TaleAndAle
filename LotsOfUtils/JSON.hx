


class _Object{
	var properties : Map<String, _Value> = null;
}

class _Array{
	var elements : Array<_Value> = null;
}

class _Value{

	public static inline var NUMBER = 1;
	public static inline var BOOLEAN = 2;
	public static inline var STRING = 3;
	public static inline var OBJECT = 4;
	public static inline var ARRAY = 5;

	var type = OBJECT;
	
	var numberValue = 1.0;
	var booleanValue = false;
	var stringValue = "";
	var objectValue : _Object = null;
	var arrayValue : _Array = null;
	
	function getValue() : Dynamic{
		switch(type){
			case NUMBER: return numberValue;
			case BOOLEAN: return booleanValue;
			case STRING: return stringValue;
			case OBJECT: return objectValue;
			case ARRAY: return arrayValue;
		}
	}
	
}

class JSON{
	
	
	
}