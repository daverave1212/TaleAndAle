package scripts;

class InventoryItem<T>{

	public var data : T;
	public var hasData : Bool = false;
	
	
	public function new(?t : T){
		if(t != null){
			data = t;
		}
	}
}

class Inventory<T>
{
	public var matrix : Matrix<T>;
	public var nRows : Int;
	public var nCols : Int;
	
	public function new(_nRows : Int, _nCols : Int){
		nRows = _nRows;
		nCols = _nCols;
		matrix = new Matrix<T>(nRows, nCols);
	}
	
	public function getFirstEmpty(?from : Vector2Int){	// Returns the first empty slot (first null slot)
		if(from == null){
			for(i in 0...nRows){
				for(j in 0...nCols){
					if(get(i, j) == null){
						return new Vector2Int(j, i);
					}
				}
			}
			return null;
		} else {
			var i = from.y;
			var j = from.x;
			while(i < nRows){
				if(get(i, j) == null)
					return new Vector2Int(j, i);
				j++;
				if(j == nCols){
					j = 0;
					i++;
				}
			}
			return null;	
		}	
	}
	
	public function remove(i : Int, j : Int){
		matrix.set(i, j, null);
	}
	
	public function add(t : T){				// Returns true if add was successful
		var emptyPos = getFirstEmpty();
		if(emptyPos == null) return false;
		var i = emptyPos.y;
		var j = emptyPos.x;
		matrix.set(i, j, t);
		return true;
	}
	
	public function get(i : Int, j : Int){
		return matrix.get(i, j);
	}
	
	// Returns a Vector2Int 
	public function find(t : T) : Vector2Int{
		for(i in 0...nRows){
			for(j in 0...nCols){
				if(matrix.get(i, j) == t){
					return new Vector2Int(j, i);
				}
			}
		}
		return null;
	}
	
	public function set(i : Int, j : Int, t : T){
		matrix.set(i, j, t);
	}
	
	public function addInventory(inv : Inventory<T>){
		var lastAddedPosition : Vector2Int = new Vector2Int(0, 0);
		for(i in 0...inv.nRows){
			for(j in 0...inv.nCols){
				if(inv.get(i, j) == null) continue;
				lastAddedPosition = getFirstEmpty(lastAddedPosition);
				matrix.set(lastAddedPosition.y, lastAddedPosition.x, inv.get(i, j));
			}
		}
	}
	
	
	// Just redo the whole ting
	// Matrix might be k tho
	
	public function addArray(a : Array<T>){
		var lastAddedPosition : Vector2Int = new Vector2Int(0, 0);
		for(i in 0...a.length){
			lastAddedPosition = getFirstEmpty(lastAddedPosition);
			matrix.set(lastAddedPosition.y, lastAddedPosition.x, a[i]);
		}
	}
	
	// For debug
	public static function printFloat(inv : Inventory<Float>){
		var ret = "";
		for(i in 0...inv.nRows){
			for(j in 0...inv.nCols){
				ret += inv.get(i, j) + " ";
			}
			trace(ret);
			ret = "";
		}
	}

	
}
