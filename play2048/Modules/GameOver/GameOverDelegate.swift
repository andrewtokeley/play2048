//
//  GameOverDelegate.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

enum GameOverOption {
    case playAgain
    case close
}

protocol GameOverDelegate {
    
    func gameOver(didSelectOption option: GameOverOption)
    
}
