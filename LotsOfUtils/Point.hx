
class Point
{
	public var x : Float;
	public var y : Float;

	public function new(?v : Point, ?_x : Float, ?_y : Float)
	{
		if(v != null){
			x = v.x;
			y = v.y;
		} else {
			x = _x;
			y = _y;
		}
	}

	public function add(v : Point){
		x += v.x;
		y += v.y;
	}

	public function withAddedX(x) {
		x += x;
		return this;
	}
	public function withAddedY(y) {
		y += y;
		return this;
	}

	public function toString(){
		return x + ", " + y;
	}

	
}