//
//  TileSetTests.swift
//  play2048Tests
//
//  Created by Andrew Tokeley on 10/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import XCTest
@testable import play2048


class TileSetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsInBounds() {
        
        let set = TileSet(rows: 4, columns: 4)
        
        // these aren't in bounds
        XCTAssertFalse(set.isInBounds(GridReference(row: 0, column: 0)))
        XCTAssertFalse(set.isInBounds(GridReference(row: 1, column: 0)))
        XCTAssertFalse(set.isInBounds(GridReference(row: 0, column: 1)))
        XCTAssertFalse(set.isInBounds(GridReference(row: 5, column: 5)))
        
        // these all are
        XCTAssert(set.isInBounds(GridReference(row: 1, column: 1)))
        XCTAssert(set.isInBounds(GridReference(row: 4, column: 4)))
        XCTAssert(set.isInBounds(GridReference(row: 2, column: 2)))
    }
    
//    func testGetIndex() {
//        let set = TileSet(rows: 4, columns: 4)
//
//        if let index = set.indexFromGridReference(GridReference(row: 1, column: 1)) {
//            XCTAssert(index == 0)
//
//            if let index = set.indexFromGridReference(GridReference(row: 4, column: 4)) {
//                XCTAssert(index == 15)
//
//                if let index = set.indexFromGridReference(GridReference(row: 3, column: 1)) {
//                    XCTAssert(index == 8)
//                } else {
//                    XCTFail()
//                }
//            } else {
//                XCTFail()
//            }
//        } else {
//            XCTFail()
//        }
//    }

    func testAddTile() {
        // From this
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   -   -
        
        // To this
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   2   -
        //  -   -   -   -
        
        let reference = GridReference(row: 2, column: 3)
        let set = TileSet(rows: 4, columns: 4)
        let tile = Tile(value: 2)
        set.addTile(reference, tile: tile)
        
        // get it back to make sure it's added correctly
        let result = set.get(reference)
        XCTAssertNotNil(result.tile)
        XCTAssertTrue(result.isInsideGrid)
        XCTAssertTrue(result.gridReference?.row == 2)
        XCTAssertTrue(result.gridReference?.column == 3)
    }

    func testChangingValue() {
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   2   -
        //  -   -   -   -
        let reference = GridReference(row: 2, column: 2)
        let set = TileSet(rows: 4, columns: 4)
        set.addTile(reference, tile: Tile(value: 2))
        
        // Change value to 4
        let result1 = set.get(reference)
        result1.tile?.value = 4
        
        let result2 = set.get(reference)
        XCTAssert(result2.tile?.value == 4)
    }
    
    func testNumberOfSpaces() {
        let initialState =  [
              [  nil,  4,  8,  nil],
              [  4,  2,  4,   8],
              [  8, 16,  nil,   4],
              [ 16,  4,  nil,  2]
            ]
        
            // set up initial grid
            let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
            
        XCTAssert(set.numberOfSpaces() == 4)
    }
    func testCanMoveFalse() {
        let initialState =  [
          [  2,  4,  8,  16],
          [  4,  2,  4,   8],
          [  8, 16,  2,   4],
          [ 16,  4,  16,  2]
        ]
    
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
        
        XCTAssertFalse(set.canMove())
    }
    
    func testHighestValueTile() {
        let initialState =  [
            [nil,nil,nil,nil],
            [  4,  2,  4, 32],
            [  8, 16,  2,  4],
            [ 16,  4, 16,  2]
        ]
    
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
        
        XCTAssertTrue(set.highestTileValue == 32)
    }
    
    func testHighestValueTileWhenTwoHigh() {
        let initialState =  [
            [nil,nil,nil,nil],
            [  4,  2,  4, 32],
            [  8, 16, 32,  4],
            [ 16,  4, 16,  2]
        ]
    
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
        
        XCTAssertTrue(set.highestTileValue == 32)
    }
    
    func testHighestValueTileBoardEmpty() {
        let initialState: [[Int?]] = [
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
    
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
        
        XCTAssertTrue(set.highestTileValue == 0)
    }
    
    func testCanMoveTrue() {
        let initialState =  [
         [  2,  4,  8,  16],
         [  4,  2,  4,  16],
         [  8, 16,  2,   4],
         [ 16,  4,  16,  2]
        ]
    
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)
        
        XCTAssertTrue(set.canMove())
    }
    
    func testAdjacentTile() {
        let initialState =  [
            [nil,nil,nil,nil],
            [nil,nil,  4,nil],
            [nil,  2,  2,  8],
            [nil,nil, 16,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let reference2x3 = GridReference(row: 2, column: 3) // middle 2
        let reference2x4 = GridReference(row: 2, column: 4) // 8
        
        XCTAssertTrue(set.getAdjacent(reference2x3, .left).tile?.value == 2)
        XCTAssertTrue(set.getAdjacent(reference2x3, .right).tile?.value == 8)
        XCTAssertTrue(set.getAdjacent(reference2x3, .up).tile?.value == 4)
        XCTAssertTrue(set.getAdjacent(reference2x3, .down).tile?.value == 16)
        
        // Space above tile2x4
        XCTAssertTrue(set.getAdjacent(reference2x4, .up).tile == nil)
        
        // Out of bounds to the right of tile2x4
        XCTAssertFalse(set.getAdjacent(reference2x4, .right).isInsideGrid)
    }
    
    func testMoveAfterMerge() {
        let initialState =  [
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [nil,  2,nil,  2],
            [nil,nil,nil,nil]
        ]
        let expectedState = [
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [  4,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        XCTAssertTrue(set.moveTiles(direction: .left))
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    func testMoveWhenNoTile() {
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   -   -
        //  -   -   -   -
        
        let set = TileSet(rows: 4, columns: 4)
        
        XCTAssertFalse(set.moveTile(GridReference(row: 2, column: 2), .down))
    }
    
    func testMoveWhenOnEdge() {
        //  -   -   -   -
        //  -   -   -   -
        //  2   -   -   -
        //  -   -   -   -
        
        let set = TileSet(rows: 4, columns: 4)
        set.addTile(GridReference(row: 2, column: 1), tile: Tile(value: 2))

        // try and move left, shouldn't do anything
        XCTAssertFalse(set.moveTile(GridReference(row: 2, column: 1), .left))
    }
    
    func testMoveAllWithMerges() {
        let initialState =  [
            [nil,nil,nil,nil],
            [nil,  4,nil,nil],
            [nil,  2,  2,nil],
            [nil,nil,nil,nil]
        ]
        let expectedState = [
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [  8,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        XCTAssertTrue(set.moveTiles(direction: .left))
        XCTAssertTrue(set.moveTiles(direction: .down))
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    
    /**
     If there are multiple matches, then the direction of the move determines precedence.
     
     If you're moving left, then the left-most match should merge first. If you're moving down, then the bottom-most match merges first, and so on.
     */
    func testMovePrecedenceDown() {
        let initialState =  [
            [nil,nil,nil,nil],
            [nil,nil,nil,  2],
            [nil,nil,nil,  2],
            [nil,nil,nil,  2]
        ]
        let expectedState = [
            [nil,nil,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,  2],
            [nil,nil,nil,  4]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let result = set.moveTiles(direction: .down)
        XCTAssertTrue(result)
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    
    /**
     If there are multiple matches, then the direction of the move determines precedence.
     
     If you're moving left, then the left-most match should merge first. If you're moving down, then the bottom-most match merges first, and so on.
     */
    func testMovePrecedenceUp() {
        
        let initialState =  [
            [nil,nil,nil,nil],
            [nil,nil,nil,  2],
            [nil,nil,nil,  2],
            [nil,nil,nil,  2]
        ]
        let expectedState = [
            [nil,nil,nil,  4],
            [nil,nil,nil,  2],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let result = set.moveTiles(direction: .up)
        XCTAssertTrue(result)
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    /**
     If there are multiple matches, then the direction of the move determines precedence.
     
     If you're moving left, then the left-most match should merge first. If you're moving down, then the bottom-most match merges first, and so on.
     */
    func testMovePrecedenceRight() {
        
        let initialState =  [
            [nil,  2,  2,  2],
            [nil,nil,nil,nil],
            [  4,  4,  4,  4],
            [nil,nil,nil,nil]
        ]
        let expectedState = [
            [nil,nil,  2,  4],
            [nil,nil,nil,nil],
            [nil,nil,  8,  8],
            [nil,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let result = set.moveTiles(direction: .right)
        XCTAssertTrue(result)
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    
    func testMovePrecedenceLeft() {
        
        let initialState =  [
            [nil,nil,nil,nil],
            [  2,  2,  2,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        let expectedState = [
            [nil,nil,nil,nil],
            [  4,  2,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let result = set.moveTiles(direction: .left)
        XCTAssertTrue(result)
        XCTAssertTrue(set.isEqualTo(expectedState))
    }
    
    func testMoveLeftWithTwoMerges() {
        let initialState =  [
            [nil,nil,nil,nil],
            [  2,  2,  4,  4],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        let expectedState = [
            [nil,nil,nil,nil],
            [  4,  8,nil,nil],
            [nil,nil,nil,nil],
            [nil,nil,nil,nil]
        ]
        
        // set up initial grid
        let set = try! TileSet(rows: 4, columns: 4, tileValues: initialState)

        let result = set.moveTiles(direction: .left)
        XCTAssertTrue(result)
        XCTAssertTrue(set.isEqualTo(expectedState), String(describing: set))
    }
    
    func testTemp() {
        let x = Tile(value: 2)
        
        let result = TileResult(tile: x, isInsideGrid: true, gridReference: nil)
        
        result.tile?.value = 123
        
        XCTAssert(x.value == 123)
    }

}
