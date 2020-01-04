//
//  GameOverSetupData.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

struct GameOverSetupData {
    var delegate: GameOverDelegate?
    var scoreValue: Int
    var highestTileValue: Int
    var hasWon: Bool
//
//    var title: String
//    var message: String
//    var collectName: Bool = false
}
