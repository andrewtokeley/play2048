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
