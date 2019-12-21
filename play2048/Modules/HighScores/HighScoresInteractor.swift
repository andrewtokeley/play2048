//
//  HighScoresInteractor.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - HighScoresInteractor Class
final class HighScoresInteractor: Interactor {
}

// MARK: - HighScoresInteractor API
extension HighScoresInteractor: HighScoresInteractorApi {
    
    func deleteHighscores(completion: (() -> Void)?) {
        
        let service = ServiceFactory.sharedInstance.scoreService
        service.deleteHighScores { (error) in
            completion?()
        }
    }
    
    func fetchHighScores() {
        let service = ServiceFactory.sharedInstance.scoreService
        service.highScores { (scores, error) in
            self.presenter.didFetchHighScores(scores: scores)
        }
    }
}

// MARK: - Interactor Viper Components Api
private extension HighScoresInteractor {
    var presenter: HighScoresPresenterApi {
        return _presenter as! HighScoresPresenterApi
    }
}
