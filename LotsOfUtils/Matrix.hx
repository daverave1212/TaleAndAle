

class Matrix<T>
{
	public var matrix : Array<Array<T>>;
	public var nRows : Int = 0;
	public var nCols : Int = 0;
	
	public function new(_nRows : Int, _nCols : Int){
		nRows = _nRows;
		nCols = _nCols;
		matrix = [for (x in 0...nRows) [for (y in 0...nCols) null]];
	}
	
	public inline function get(i : Int, j : Int) {
		return matrix[i][j];
	}

	public inline function getRow(i: Int) return matrix[i];
	public inline function getByPos(p : Position) return matrix[p.i][p.j];
	
	public inline function set(i : Int, j : Int, t : T){
		matrix[i][j] = t;
	}
	
	public function filter(func : T -> Bool, nullValue : T) {			// If func(elem), elem. Else nullValue
		var returnedMatrix = new Matrix<T>(nRows, nCols);
		for (i in 0...nRows) for (j in 0...nCols) {
			returnedMatrix.set(i, j, if (func(matrix[i][j])) matrix[i][j] else nullValue);
		}
		return returnedMatrix;
	}

	public function filterIndices(func : Int -> Int -> Bool, nullValue : T) {
		var returnedMatrix = new Matrix<T>(nRows, nCols);
		for (i in 0...nRows) for (j in 0...nCols) {
			returnedMatrix.set(i, j, if (func(i, j)) matrix[i][j] else nullValue);
		}
		return returnedMatrix;
	}

	public function filterToArray(func : T -> Bool) {
		var items : Array<T> = [];
		forEach(item -> if (func(item)) items.push(item));
		return items;
	}
	public function filterToArrayIndices(func : Int -> Int -> Bool) {
		var indices : Array<Position> = [];
		forEachIndices((i, j) -> if (func(i, j)) indices.push(new Position(i, j)));
		return indices;
	}
	public function filterToArrayIndicesToT(func : Int -> Int -> Bool) {
		var elems : Array<T> = [];
		forEachIndices((i, j) -> if (func(i, j)) elems.push(get(i, j)));
		return elems;
	}

	public function setAll(t : T){
		for (i in 0...nRows) {
			for(j in 0...nCols){
				matrix[i][j] = t;
			}
		}
		return this;
	}
	
	public function push(t : T){	// Can probably be heavily optimized
		var i = 0;
		while(i < nRows){
			var firstNull = U.getFirstNull(matrix[i]);
			if(firstNull != -1){
				matrix[i][firstNull] = t;
				return true;	// Success
			}
			i++;
		}
		return false;
	}
	
	public function forEach(doThis : T -> Void){
		for(i in 0...nRows){
			for(j in 0...nCols){
				doThis(get(i, j));
			}
		}
	}

	public function forEachIndices(doThis : Int -> Int -> Void){
		for(i in 0...nRows){
			for(j in 0...nCols){
				doThis(i, j);
			}
		}
	}
	
	public function isInBounds(i : Int, j : Int){
		if(i < 0 || i >= nRows) return false;
		if(j < 0 || j >= nCols) return false;
		return true;
	}
	public inline function isOutOfBounds(i: Int, j: Int) return !isInBounds(i, j);
	
	public static function traceIntMatrix(m : Matrix<Int>, ?message: String) {
		for (i in 0...m.nRows) {
			var line = "";
			for(j in 0...m.nCols){
				line += m.get(i, j) + " ";
			}
			if (i == 0 && message != null) {
				trace(line + '\t| ${message}');
			} else {
				trace(line);
			}
		}
	}
	
	
	
	
	
	
}