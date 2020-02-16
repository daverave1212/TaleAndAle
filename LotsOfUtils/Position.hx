


class Position
{
	public var i : Int;
	public var j : Int;

	public function new(?p : Position, ?_i : Int, ?_j : Int)
	{
		if(p != null){
			i = p.i;
			j = p.j;
		} else {
			i = _i;
			j = _j;
		}
	}

	public inline function toString(){
		return i + "," + j;
	}

	public inline function equalsPosition(p : Position) return i == p.i && j == p.j;
}