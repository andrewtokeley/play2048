//
//  GameRouter.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
//import Viperit

// MARK: - GameRouter class
final class GameRouter: Router {
}

// MARK: - GameRouter API
extension GameRouter: GameRouterApi {
    
    func showHighScoreModule() {
        let module = AppModules.highScores.build()
        module.router.show(from: viewController, embedInNavController: false, setupData: nil)
    }
}

// MARK: - Game Viper Components
private extension GameRouter {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
