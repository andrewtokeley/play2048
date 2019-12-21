//
//  Tile.swift
//  game2048
//
//  Created by Andrew Tokeley on 9/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import UIKit

class Tile {
    
    // something unique we can use to test equality in the Equatable extension
    private let id: String = UUID().uuidString
    
    var colour: UIColor {
        return colourForValue(value)
    }
    
    var forecolour: UIColor {
        return forecolourForValue(value)
    }
    
    var value: Int
    
    /// Flag indicating whether the tile as been merged within a `TileSet.move()` operation
    var hasMerged: Bool = false
    
    init(value: Int) {
        self.value = value
    }
    
    private func colourForValue(_ value: Int) -> UIColor {
        switch value {
        case 2: return .tile2
        case 4: return .tile4
        case 8: return .tile8
        case 16: return .tile16
        case 32: return .tile32
        case 64: return .tile64
        case 128: return .tile128
        case 256: return .tile256
        case 512: return .tile512
        case 1024: return .tile1024
        case 2048: return .tile2048
        default: return .white
        }
    }
    
    private func forecolourForValue(_ value: Int) -> UIColor {
        if value < 256 {
            return .gameBackground
        }
        return .white
    }
}

extension Tile: Equatable {
    static func == (left: Tile, right: Tile) -> Bool {
        return left.id == right.id
    }
}
