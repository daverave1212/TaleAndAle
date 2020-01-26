

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
	
	public function get(i : Int, j : Int){
		return matrix[i][j];
	}
	
	public function set(i : Int, j : Int, t : T){
		matrix[i][j] = t;
	}
	
	public function setAll(t : T){
		for(i in 0...nRows){
			for(j in 0...nCols){
				matrix[i][j] = t;
			}
		}
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
	
	public static function traceIntMatrix(m : Matrix<Int>){
		for(i in 0...m.nRows){
			var line = "";
			for(j in 0...m.nCols){
				line += m.get(i, j) + " ";
			}
			trace(line);
		}
	}
	
	
	
	
	
	
}