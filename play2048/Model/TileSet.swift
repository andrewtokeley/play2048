//
//  TileSet.swift
//  game2048
//
//  Created by Andrew Tokeley on 9/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

enum TileSetError: Error {
    case OutOfBounds
    case IncorrectNumberOfTileValues
}

enum GridElementState {
    case Empty
    case OutOfBounds
}

/** A TileSet represents all the spaces in a grid. If a Tile exists at a (r, c) location it can be accessed, if no tile exists it is represented by a nil.
 - note:
*/
class TileSet {
    
    // MARK: - Variables
    
    /// Delegate protocol that let's implementations know of certain tile events
    var delegate: TileSetDelegate?
    
    /// Delegate to pass grid movement events to
    var gridDelegate: TileSetGridDelegate?
    
    /**
     Internal representation of the tiles. A nil element mean there is no tile at that position.
     
    - Important:
     This array is intentially index 1 based. tiles[0,\*] and tiles[\*,0] should be ignored.
    */
    private var tiles: [[Tile?]]!
    
    /// number of rows in grid
    var rows: Int
    
    /// number of columns in grid
    var columns: Int
    
    /// Returns the highest value amongst all tiles
    var highestTileValue: Int {
        
        /// Yikes
        let max = tiles.max { (tileRow1, tileRow2) -> Bool in
            let maxTileRow1 = (tileRow1.max { return $0?.value ?? 0 < $1?.value ?? 0 })??.value ?? 0
            let maxTileRow2 = (tileRow2.max { return $0?.value ?? 0 < $1?.value ?? 0 })??.value ?? 0
            return maxTileRow1 < maxTileRow2
            }?.max { $0?.value ?? 0 < $1?.value ?? 0}
        
        return max??.value ?? 0
    }
    
    // MARK: Initialisers
    
    /// initializer
    convenience init(rows: Int, columns: Int) {
        try! self.init(rows: rows, columns: columns, tileValues: Array(repeating: Array(repeating: nil, count: columns), count: rows) )
    }
    
    /**
     Initialise new TileSet
     
     - Parameters:
        - rows: number of rows in the set
        -  columns: number of columns in the set
        - tileValues: zero index based, 2D array of tile values. Importantly, the rows in the array are in reverse order to make it easier when setting this parameter from unit tests. That is, the row at index 0 is actually row 4 of a 4x4 grid.
     */
    init(rows: Int, columns: Int, tileValues: [[Int?]]) throws {
        guard tileValues.count == rows else { throw TileSetError.IncorrectNumberOfTileValues }
        
        self.rows = rows
        self.columns = columns
        
        // initialise array to be one more row and column than the count since we are treating all zeros as 1 based not 0.
        self.tiles = Array(repeating: Array(repeating: nil, count: columns + 1), count: rows + 1)
        
        for r in 1...rows {
            let row = tileValues[r-1]
            
            // every element (row) of the array must be an array of length equal to the number of columns
            if row.count != columns { throw TileSetError.IncorrectNumberOfTileValues }

            for c in 1...columns {
                if let value = tileValues[rows - r][c-1] {
                    tiles[r][c] = Tile(value: value)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func numberOfSpaces() -> Int {
        var count = 0
        for r in 1...rows {
            for c in 1...columns {
                if tiles[r][c] == nil { count += 1}
            }
        }
        return count
    }
        
    /**
     Returns a `GridReference` pointing to a random space in the grid. If there are no spaces the method returns nil.
     */
    func randomSpaceGridReference() -> GridReference? {
        
        let spaces = numberOfSpaces()
        
        if spaces > 0 {
            let random = Int.random(in: 0..<spaces)
            var count = 0
            for r in 1...rows {
                for c in 1...columns {
                    if tiles[r][c] == nil {
                        if count == random {
                            return GridReference(row: r, column: c)
                        }
                        count += 1
                    }
                }
            }
        }
        return nil
    }
    
    /**
     Returns whether the (r, c) coordinates are inside the bounds of the grid
     
     - Parameters:
        - reference: GridReference to check whether it's inside the grid dimensions
     */
    func isInBounds(_ reference: GridReference) -> Bool {
        
        let r = reference.row
        let c = reference.column

        return r <= rows && r > 0 && c <= columns && c > 0
    }
    
    // MARK: - Get Tiles
    
    /**
     Returns the raw underlying array of `Tile` records
     */
    func get() -> [[Tile?]] {
        return tiles
    }
    
    /**
     Returns a `TileResult` instance for the tile at position(r, c).

     The result can indicate one of three things.
     
     - There is a valid tile at the location (`TileResult.tile` will be non-nil and `TileResult.isInsideGrid` will be `true`)
     - There is a space at the location (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `true`)
     - The location is outside the dimensions of the grid (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `false`)
     
     - Parameters:
        - reference: GridReference to look for the tile
     
     - Returns: A `TileResult` instance representing the tile, or absense of a tile, located at position (r, c)
    */
    func get(_ reference: GridReference) -> TileResult  {
        
        let isInsideGrid = isInBounds(reference)
        
        return TileResult(tile: isInsideGrid ? tiles[reference.row][reference.column] : nil, isInsideGrid: isInsideGrid, gridReference: reference)
        
    }
    
    /**
     Returns the tile in the adjacent direction to the specified location.
     
     The result can indicate one of three things.
     
     - There is a valid tile at the adjacent location (`TileResult.tile` will be non-nil and `TileResult.isInsideGrid` will be `true`)
     - There is a space at the adjacent location (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `true`)
     - The adjacent location is outside the dimensions of the grid (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `false`)
     
     - Parameters:
        - reference: GridReference of the tile from which you want to find the adjacent tile
        - direction: The `Direction` of the adjacent tile
     
     - Returns: A `TileResult` instance representing the adjacent tile, or absense of the adjacent tile.
     */
    func getAdjacent(_ reference: GridReference, _ direction: Direction) -> TileResult {
        
        let adjacentReference = GridReference(row: reference.row + direction.delta.rowDelta, column:reference.column + direction.delta.columnDelta)
        
        return get(adjacentReference)
    }
    
    // MARK: - Move Tiles
    
    /**
     If possible, moves a tile in the direction specified.
     
     If the tile can not move in that direction, because there's a competing tile in the way or the tile is at the edge of the grid, no changes are made.
     
     If the adjacent tile's value matches the moving tile's value, they are merged and the moving tile's value will be doubled.
     
     If there is no adjacent tile and the moving tile has space to move into, it will be moved in the given direction.
     
     - Parameters:
        - reference: GridReference of the tile to move
        - direction: The `Direction` to move
        - iteration: Tiles are moved in iterations. Each iteration does a scan of the grid to see which tiles can be moved/merged. The iteration is passed to the `GridDelegate`to assist the order of move animations.
     - Returns: Flag indicating whether the move resulted in a tile moving or not.
     */
    func moveTile(_ reference: GridReference, _ direction: Direction, iteration: Int) -> Bool {
        
        // get the tile that's moving
        let movingTileResult = get(reference)
        
        // if this location doesn't have a tile, nothing to do
        if movingTileResult.tile == nil {
            return false
        }
        
        // get the tile that's adjacent to this tile in the direction it's moving
        let adjacentTileResult = getAdjacent(reference, direction)
        
        // if the adjacent tile isn't in the grid then we can't move
        if !adjacentTileResult.isInsideGrid {
            return false
        }
        
        // if there is an adjacent tile, check the values are equal before moving
        if let adjacentTile = adjacentTileResult.tile, let movingTile = movingTileResult.tile {
            
            // check if they have the same value and neither have been merged before
            if movingTile.value == adjacentTile.value && (!movingTile.hasMerged && !adjacentTile.hasMerged)  {
               
                // double the moving tiles's value
                movingTile.value = movingTile.value * 2
                
                // prevent this tile from merging again in a moveAll operation
                movingTile.hasMerged = true
                
                // remove reference to the moving cell in it's original location
                tiles[reference.row][reference.column] = nil
                
                // let delegate know the tile was removed
                gridDelegate?.tileSet(self, tileRemovedFrom: adjacentTileResult.gridReference!, iteration: iteration)
                
                // put the movingTile in the adjacent location
            tiles[adjacentTileResult.gridReference!.row][adjacentTileResult.gridReference!.column] = movingTile
                
                // tell the delegate the movingTile has moved
                gridDelegate?.tileSet(self, tileMovedFrom: reference, inDirection: direction, iteration: iteration)
                    
                    // ...and that it's value is new
                gridDelegate?.tileSet(self, tileValueChangedTo: movingTile.value, at: adjacentTileResult.gridReference!, iteration: iteration)
                    
                    // ...and that the moving tile matched
                delegate?.tileSet(self, didMatchTile: movingTile)
                
                // successful merge
                return true
            }
        } else {
            
            // if we can move into the adjacent space, then do it
            if let adjacentTileReference = adjacentTileResult.gridReference {
                
                // Point the adjacent location to the moving tile
                tiles[adjacentTileReference.row][adjacentTileReference.column] = movingTileResult.tile
                    
                // Remove the original reference to the moving tile
            tiles[movingTileResult.gridReference!.row][movingTileResult.gridReference!.column] = nil
                
                // successful move into free space
                gridDelegate?.tileSet(self, tileMovedFrom: movingTileResult.gridReference!, inDirection: direction, iteration: iteration)
                
                return true
            
            }
        }
        
        // if you got here then you didn't move anything
        return false
    }
    
    /**
     Moves all tiles as far as possible in the chosen direction.
     
     - Parameters:
        - direction: the direction in which to moves tiles
        - completion: optional closure called once the move operations have completed. It takes a single Bool argument to indicate if any tiles moved
     */
    func moveTiles(direction: Direction, completion: ((Bool) -> Void)?) {
        
        // Clear merge states on all tiles
        for rows in tiles {
            for tile in rows {
                tile?.hasMerged = false
            }
        }
        
        // To ensure merge precedence we scan the rows and columns according to the direction
        // up - scan top to bottom
        // down - scan bottom to top
        // left - scan left to right
        // right - scan right to left
        var rRange = stride(from: 1, to: rows+1, by: 1)
        var cRange = stride(from: 1, to: columns+1, by: 1)
        if direction == .up { rRange = stride(from: rows, to: 0, by: -1)}
        if direction == .right { cRange = stride(from: columns, to: 0, by: -1) }
        
        // set to 1 to ensure we try at least one iteration
        var numberOfMovedTiles = -1
        var iteration = 0
        var movedSome = false
        while numberOfMovedTiles != 0 {
            numberOfMovedTiles = 0
            iteration += 1
            for r in rRange {
                for c in cRange {
                    let reference = GridReference(row: r, column: c)
                    
                    if (moveTile(reference, direction, iteration: iteration)) {
                        //print("Moved from \(reference) in direction \(direction)")
                        movedSome = true
                        numberOfMovedTiles += 1
                    }
                }
            }
        }
        
        completion?(movedSome)
    }
    
    /**
     Returns whether there are any valid moves left.
     */
    func canMove() -> Bool {

        // if there are any spaces you must be able to move
        if numberOfSpaces() > 0 {
            return true
        } else {
            // if there are no spaces but there are adjacent and equal tiles, you can still move
            for r in 1...rows {
                for c in 1...columns {
                    
                    // check adjacent tiles
                    let value = get(GridReference(row: r, column: c)).tile!.value
                    
                    let upValue = get(GridReference(row: r + Direction.up.delta.rowDelta, column: c + Direction.up.delta.columnDelta)).tile?.value
                    let downValue = get(GridReference(row: r + Direction.down.delta.rowDelta, column: c + Direction.down.delta.columnDelta)).tile?.value
                    let leftValue = get(GridReference(row: r + Direction.left.delta.rowDelta, column: c + Direction.left.delta.columnDelta)).tile?.value
                    let rightValue = get(GridReference(row: r + Direction.right.delta.rowDelta, column: c + Direction.right.delta.columnDelta)).tile?.value
                    
                    if [upValue, downValue, leftValue, rightValue].contains(value) {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    // MARK: - Add Tiles
    
    /**
     Adds a `Tile` at the given grid reference
     
     If there is already a tile at the given location it will be replaced.
     
     - Parameters:
        - reference: `GridReference` representing the location to add the tile
        - tile: the tile to add to the grid
     */
    func addTile(_ reference: GridReference, tile: Tile) {
        tiles[reference.row][reference.column] = tile
        gridDelegate?.tileSet(self, tileAdded: tile, reference: reference)
    }
    
    /**
     Adds a tile to the grid at a random location
     */
    func addTileToRandomSpace(tile: Tile) {
        if let reference = randomSpaceGridReference() {
            self.addTile(reference, tile: tile)
        }
    }
    
    // MARK: Test Helpers
    
    /**
     Helper function used only in unit tests to compare state after test runs.
     
     - Parameters:
        - values: zero index based, 2D array of tile values. Importantly, the rows in the array are in reverse order to make it easier when setting this parameter from unit tests. That is, the row at index 0 is actually row 4 of a 4x4 grid.
     */
    func isEqualTo(_ values: [[Int?]]) -> Bool {
        
        for r in 1...rows {
            for c in 1...columns {
                if tiles[r][c]?.value != values[rows-r][c - 1] {
                    return false
                }
            }
        }
        
        // if you get here then all the values are equal
        return true
    }
}

// MARK: - CustomDebugStringConvertible

extension TileSet: CustomDebugStringConvertible {
    var debugDescription: String {
        
        var result = ""
        let leading = "     "
        
        for r in 1...rows {
            var row: String = ""
            for c in 1...columns {
                
                //let ref = GridReference(row: r, column: c)
                let value = tiles[r][c]?.value //get(ref).tile?.value
                let valueString = value == nil ? "-" : String(value!)
                row.append(leading.suffix(leading.count - valueString.count).description)
                row.append(valueString)
            }
            row.append("\n")
            
            result.insert(contentsOf: row, at: result.startIndex)
            
        }
        return result
    }
}
