
package scripts;

import com.stencyl.Engine;

class Pathing
{
	// Marks up, right, down and left if they are not already marked
	private static function markAdjacentSpotsOnMatrix(m : Matrix<Int>, givenX : Int, givenY : Int, remainingRange : Int){
		if(givenX < 0 || givenX >= m.nCols || givenY < 0 || givenY >= m.nRows)
			return;
		if(m.get(givenY, givenX) == 1 || Battlefield.tiles.get(givenY, givenX).unitOnIt != null)
			return;
		m.set(givenY, givenX, 1);
		if(remainingRange == 1)
			return;
		markAdjacentSpotsOnMatrix(m, givenX - 1, givenY, remainingRange - 1);
		markAdjacentSpotsOnMatrix(m, givenX + 1, givenY, remainingRange - 1);
		markAdjacentSpotsOnMatrix(m, givenX, givenY - 1, remainingRange - 1);
		markAdjacentSpotsOnMatrix(m, givenX, givenY + 1, remainingRange - 1);}
		
	// Graph-searches our tile matrix and returns a matrix of 1's and 0's
	// Sets the matrix containing 1's on places where the mapping succeeds
	public static function mapMatrixForTilesInRange(mtx : Matrix<Int>, x : Int, y : Int, range : Int){
		var m = mtx;
		m.setAll(0);
		markAdjacentSpotsOnMatrix(m, x - 1, y, range);		// I don't start at the center
		markAdjacentSpotsOnMatrix(m, x + 1, y, range);		// because of this line in the if above:
		markAdjacentSpotsOnMatrix(m, x, y - 1, range);		// tiles.get(givenY, givenX).unitOnIt != null
		markAdjacentSpotsOnMatrix(m, x, y + 1, range);		// So we start at all adjacent tiles
	}
	
	public static function mapMatrixForSkillShot(mtx : Matrix<Int>, originTile : TileSpace, spellBeingCast : Spell){
		var x = originTile.matrixX;
		var y = originTile.matrixY;
		var m = mtx;
		var spellType = spellBeingCast.spellType;
		m.setAll(0);
		if(spellType.SkillShot_down){
			var iMax = Std.int(Math.min(Battlefield.nTileRows, y + spellType.range + 1));
			for(i in y + 1...iMax){
				m.set(i, x, 1);
				if(Battlefield.tiles.get(i, x).hasUnit())
					break;
			}}
		if(spellType.SkillShot_right){
			var iMax = Std.int(Math.min(Battlefield.nTileCols, x + spellType.range + 1));
			for(i in x + 1...iMax){
				m.set(y, i, 1);
				if(Battlefield.tiles.get(y, i).hasUnit())
					break;
			}}
		if(spellType.SkillShot_up){							// Because Haxe doesn't support for
			var iMin = Math.max(0, y - spellType.range);	// which decreases... smh
			var i = y; while(i > iMin){ i--;			
				m.set(i, x, 1);
				if(Battlefield.tiles.get(i, x).hasUnit())
					break;
			}}
		if(spellType.SkillShot_left){						// Because Haxe doesn't support for
			var iMin = Math.max(0, x - spellType.range);	// which decreases... smh
			var i = x; while(i > iMin){ i--;				
				m.set(y, i, 1);
				if(Battlefield.tiles.get(y, i).hasUnit())
					break;
			}}
	}
	
	public static function mapMatrixForAnyAlly(mtx : Matrix<Int>, castingUnit : Unit, spellBeingCast : Spell){
		var m = mtx;
		m.setAll(0);
		for(i in 0...Battlefield.nTileRows)
			for(j in 0...Battlefield.nTileCols){
				var thisTile = Battlefield.tiles.get(i, j);
				if(thisTile.hasUnit()){
					var thisUnit = thisTile.unitOnIt;
					if(thisUnit == castingUnit && !spellBeingCast.allowSelf()) continue;
					if(thisUnit.owner != castingUnit.owner) continue;		// Same owner
					trace(thisUnit.name + " - " + thisUnit.owner);
					trace(castingUnit.name + " - " + castingUnit.owner);
					m.set(i, j, 1);
				}
			}
	}

}
	
	