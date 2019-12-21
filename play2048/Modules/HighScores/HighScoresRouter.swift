//
//  HighScoresRouter.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - HighScoresRouter class
final class HighScoresRouter: Router {
}

// MARK: - HighScoresRouter API
extension HighScoresRouter: HighScoresRouterApi {
}

// MARK: - HighScores Viper Components
private extension HighScoresRouter {
    var presenter: HighScoresPresenterApi {
        return _presenter as! HighScoresPresenterApi
    }
}
