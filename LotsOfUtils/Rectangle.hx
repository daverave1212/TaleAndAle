

class Rectangle{
	
	public var x : Float;
	public var y : Float;
	public var width : Float;
	public var height : Float;
	
	public function new(_x, _y, w, h){
		x = _x;
		y = _y;
		width = w;
		height = h;
	}
	
	public inline function toString(){
		return (x + ", " + y + "  " + width + "x" + height);
	}
	
}