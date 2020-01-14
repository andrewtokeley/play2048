//
//  Direction.swift
//  game2048
//
//  Created by Andrew Tokeley on 9/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

struct DirectionDelta {
    var rowDelta: Int
    var columnDelta: Int
}

/// Enumerator representing the direction a user decides to swipe
enum Direction {
    case up
    case down
    case left
    case right
    
    var delta: DirectionDelta {
        switch self {
        case .up: return DirectionDelta(rowDelta: 1, columnDelta: 0)
        case .down: return DirectionDelta(rowDelta: -1, columnDelta: 0)
        case .left: return DirectionDelta(rowDelta: 0, columnDelta: -1)
        case .right: return DirectionDelta(rowDelta: 0, columnDelta: 1)
        }
    }

}
