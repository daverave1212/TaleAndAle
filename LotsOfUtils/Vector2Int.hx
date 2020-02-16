


class Vector2Int
{
	public var x : Int;
	public var y : Int;

	public function new(?v : Vector2Int, ?_x : Int, ?_y : Int)
	{
		if(v != null){
			x = v.x;
			y = v.y;
		} else {
			x = _x;
			y = _y;
		}
	}

	public function add(v : Vector2Int){
		x += v.x;
		y += v.y;
	}

	public function toString(){
		return x + ", " + y;
	}
}