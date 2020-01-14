//
//  TileSetDelegate.swift
//  play2048
//
//  Created by Andrew Tokeley on 11/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

protocol TileSetDelegate {
    func tileSet(_ tileSet: TileSet, didMatchTile tile: Tile)
    func tileSet(_ tileSet: TileSet, highestTileValue: Int)
}

protocol TileSetGridDelegate {
    func tileSet(_ tileSet: TileSet, tileMovedFrom from: GridReference, inDirection direction: Direction, iteration: Int)
    func tileSet(_ tileSet: TileSet, tileRemovedFrom from: GridReference, iteration: Int)
    func tileSet(_ tileSet: TileSet, tileValueChangedTo newValue: Int, at: GridReference, iteration: Int)
    func tileSet(_ tileSet: TileSet, tileAdded tile: Tile, reference: GridReference)
}
