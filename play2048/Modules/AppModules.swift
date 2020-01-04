//
//  AppModules.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation


//MARK: - Application modules
enum AppModules: String, ViperitModule {
    case game
    case highScores
    case loader
    case gameOver
    
    var viewType: ViperitViewType {
        if self == .loader {
            return .storyboard
        } else {
            return .code
        }
    }
}
