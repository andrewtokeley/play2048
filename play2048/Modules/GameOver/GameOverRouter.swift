//
//  GameOverRouter.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - GameOverRouter class
final class GameOverRouter: Router {
}

// MARK: - GameOverRouter API
extension GameOverRouter: GameOverRouterApi {
}

// MARK: - GameOver Viper Components
private extension GameOverRouter {
    var presenter: GameOverPresenterApi {
        return _presenter as! GameOverPresenterApi
    }
}
