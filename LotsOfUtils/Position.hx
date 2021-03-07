


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

	public inline function equals(_i: Int, _j: Int) return i == _i && j == _j;

	public static function createFromDynamic(p : Dynamic) {
		var newI : Int = cast p.i;
		var newJ : Int = cast p.j;
		return new Position(newI, newJ);
	}
}