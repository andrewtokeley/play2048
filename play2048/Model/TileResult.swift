//
//  TileResult.swift
//  game2048
//
//  Created by Andrew Tokeley on 9/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

/**
 Represents the result of a `Tile` search,
 
 The result can indicate one of three things.
 
 - There is a valid tile at the adjacent location (`TileResult.tile` will be non-nil and `TileResult.isInsideGrid` will be `true`)
 - There is a space at the adjacent location (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `true`)
 - The adjacent location is outside the dimensions of the grid (`TileResult.tile` will be nil and `TileResult.isInsideGrid` will be `false`)
 
 */
class TileResult {
    
    /// Tile instance returned from a tile search function i.e. get(r, c). Nil can indicate that a tile at the requested location doesn't exist (i.e. there's a space there) or that the requested location is outside the bounds of the grid. If the latter, the isInsideGrid flag will be set to false.
    var tile: Tile?
    
    /// Returns whether the requested tile is inside the bounds of the grid
    var isInsideGrid: Bool
    
    /// If there is a valid tile or simply a space inside the grid, this is the grid reference to it
    var gridReference: GridReference?
    
    /// Create a new instance of `TileResult`
    init(tile: Tile?, isInsideGrid: Bool, gridReference: GridReference?) {
        self.tile = tile
        self.isInsideGrid = isInsideGrid
        self.gridReference = gridReference
    }
}
