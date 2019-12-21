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
    
    /// private representation of the tiles. Nils mean there is no tile at that position
    private var tiles: [Tile?]
    
    /// number of rows in grid
    var rows: Int
    
    /// number of columns in grid
    var columns: Int
    
    var highestTileValue: Int {
        if let maxTile = tiles.max(by: { $0?.value ?? 0 < $1?.value ?? 0}) {
            return maxTile?.value ?? 0
        } else {
            return 0
        }
    }
    
    // MARK: Initialisers
    
    /// initializer
    convenience init(rows: Int, columns: Int) {
        try! self.init(rows: rows, columns: columns, tileValues: [Int?].init(repeating: nil, count: rows * columns))
    }
    
    init(rows: Int, columns: Int, tileValues: [Int?]) throws {
        guard rows * columns == tileValues.count else { throw TileSetError.IncorrectNumberOfTileValues }
        
        self.rows = rows
        self.columns = columns
        self.tiles = [Tile?]()
        for i in 0..<(rows * columns) {
            let value = tileValues[i]
            self.tiles.append(value != nil ? Tile(value: value!) : nil)
        }
    }
    
    // MARK: - Helpers
    
    /**
     Returns a `GridReference` pointing to a random space in the grid. If there are no spaces the method returns nil.
     */
    func randomSpaceGridReference() -> GridReference? {
        guard tiles.contains(nil) else { return nil }
        
        // find a random space
        let spaceTiles = tiles.filter({ $0 == nil })
        let random = Int.random(in: 0..<spaceTiles.count)
        
        var count = 0
        for r in 1...rows {
            for c in 1...columns {
                let reference = GridReference(row: r, column: c)
                if get(reference).tile == nil {
                    if count == random {
                        return reference
                    }
                    count += 1
                }
            }
        }
        return nil
    }
    
    /// Converts a grid reference into the index of the underlying tile array
    func indexFromGridReference(_ reference: GridReference) -> Int? {
        if isInBounds(reference) {
            let r = reference.row
            let c = reference.column
            return columns * (r - 1) + c - 1
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
    func get() -> [Tile?] {
        return tiles
    }
    
    /**
     Returns an array of the underlying values. The first value in the array is (1, 1) followed by (1,2) and ending in (r, c)
     */
    func getValues() -> [Int?] {
        return tiles.map({ $0?.value ?? nil })
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
        
        let index = indexFromGridReference(reference)
        
        return TileResult(tile: index != nil ? tiles[index!] : nil, isInsideGrid: isInsideGrid, gridReference: reference)
        
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
     
     If the adjacent tile's value matches the moving tile's value, they are merged and the adjacent tile's value will double.
     
     If there is no adjacent tile and the moving tile has space to move into, it will be moved in the given direction.
     
     - Parameters:
        - reference: GridReference of the tile to move
        - direction: The `Direction` to move
     
     - Returns: Flag indicating whether the move resulted in a tile moving or not.
     */
    func moveTile(_ reference: GridReference, _ direction: Direction) -> Bool {
                
        // get the tile that's moving
        let tileToMoveResult = get(reference)
        
        // if this location doesn't have a tile, nothing to do
        if tileToMoveResult.tile == nil {
            return false
        }
        
        // get the tile that's adjacent to this tile in the direction it's moving
        let adjacentTileResult = getAdjacent(reference, direction)
        
        // if there is an adjacent tile, check the values are equal before moving
        if let adjacentTile = adjacentTileResult.tile {
            
            // check if they have the same value and neither have been merged before)
            if tileToMoveResult.tile!.value == adjacentTile.value && (!tileToMoveResult.tile!.hasMerged && !adjacentTile.hasMerged)  {
               
                // double it's value
                adjacentTile.value = adjacentTile.value * 2
                
                delegate?.tileSet(self, didMatchTile: adjacentTile)
                
                // prevent this tile from merging again in a moveAll operation
                adjacentTile.hasMerged = true
                
                // remove the moving tile as it's merged with the adjancent one
                if let index =  indexFromGridReference(tileToMoveResult.gridReference!){
                    tiles[index] = nil
                }
                
                // successful merge
                return true
            }
        } else {
            
            // if we can move into the adjacent space, then do it
            if let adjacentTileReference = adjacentTileResult.gridReference {
                
                if let indexOfAdjacentTile = indexFromGridReference(adjacentTileReference) {
                    
                    // Point the adjacent location to the moving tile
                    tiles[indexOfAdjacentTile] = tileToMoveResult.tile
                    
                    // Remove the original reference to the moving tile
                    if let index =  indexFromGridReference(tileToMoveResult.gridReference!){
                        tiles[index] = nil
                    }
                    
                    // successful move into space
                    return true
                }
            }
        }
        
        // if you got here then you didn't move anything
        return false
    }
    
    /**
     Moves all tiles as far as possible in the chosen direction.
     
     - Parameters:
        - direction: the direction in which to moves tiles
     
     - Returns: A flag indicating whether any tiles were moved.
     */
    func moveTiles(direction: Direction) -> Bool {
        
        // Clear merge states on all tiles
        for tile in tiles {
            tile?.hasMerged = false
        }
        
        // To ensure merge precedence we scan the rows and columns according to the direction
        // up - scan top to bottom
        // down - scan bottom to top
        // left - scan left to right
        // right - scan right to left
        var rRange = stride(from: 1, to: rows+1, by: 1)
        var cRange = stride(from: 1, to: columns+1, by: 1)
        if direction == .down { rRange = stride(from: rows, to: 0, by: -1)}
        if direction == .right { cRange = stride(from: columns, to: 0, by: -1) }
        
        // set to 1 to ensure we try at least one iteration
        var numberOfMovedTiles = -1
        var movedSome = false
        while numberOfMovedTiles != 0 {
            numberOfMovedTiles = 0
            for r in rRange {
                for c in cRange {
                    let reference = GridReference(row: r, column: c)
                    if (moveTile(reference, direction)) {
                        movedSome = true
                        numberOfMovedTiles += 1
                    }
                }
            }
        }
        
        return movedSome
    }
    
    /**
     Returns whether there are any valid moves left.
     */
    func canMove() -> Bool {

        // if there are any spaces you can move
        if tiles.filter({$0 == nil }).count > 0 {
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
        if let index = indexFromGridReference(reference) {
            tiles[index] = tile
        }
    }
    
    /**
     Adds a tile to the grid at a random location
     */
    func addTileToRandomSpace(tile: Tile) {
        if let reference = randomSpaceGridReference() {
            if let index = indexFromGridReference(reference) {
                tiles[index] = tile
            }
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension TileSet: CustomDebugStringConvertible {
    var debugDescription: String {
        
        var result: String = ""
        let leading = "     "
        
        for r in 1...rows {
            for c in 1...columns {
                let ref = GridReference(row: r, column: c)
                let value = get(ref).tile?.value
                let valueString = value == nil ? "-" : String(value!)
                result.append(leading.suffix(leading.count - valueString.count).description)
                result.append(valueString)
            }
            // newline
            result.append("\n")
        }
        return result
    }
}
