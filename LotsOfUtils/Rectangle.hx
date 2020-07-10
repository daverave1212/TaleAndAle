

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

	public inline function containsPoint(point : Point){
		return containsCoordinates(point.x, point.y);
	}

	public inline function containsCoordinates(_x : Float, _y : Float){
		return (x <= _x) && (_x <= x + width) && (y <= _y) && (_y <= y + height);
	}
	
}