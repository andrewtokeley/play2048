//
//  GameOverInteractor.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - GameOverInteractor Class
final class GameOverInteractor: Interactor {
}

// MARK: - GameOverInteractor API
extension GameOverInteractor: GameOverInteractorApi {
    
    func endOfGameTitleAndMessage(won: Bool, isTopTen: Bool, isHighScore: Bool) -> (title: String, message: String) {
        
        let title = won ? "You Won!" : "Game Over!"
        
        var message =
            won && isHighScore ? "Nice work, you reached 2048 AND got a new highscore. Wahoo!" :
                (won && isTopTen ? "Nice work, you reached 2048 AND got a top ten score" :
                    (won && !isTopTen ? "Nice work, you reached 2048! No highscore this time, sorry!" :
                        (!won && isHighScore ? "YUS, new highscore!" :
                            (!won && isTopTen ? "NOOICE, top 10 score!" : ""))))
        
        if isTopTen {
          message += "\n\nEnter your initals (up to 5 characters)"
        } else {
          message += "\n\nDo you want to play again?"
        }
        return (title: title, message: message)
    }
    
    /**
     Save score to data store
     */
    func saveScore(score: Score, completion: ((Score?, Error?) -> Void)?) {
        
        let service = ServiceFactory.sharedInstance.scoreService
        service.addScore(score: score) { (score, error) in
            completion?(score, error)
        }
    }
    
    /**
    Checks the current score for high score status.
    
    The closure returns two parameters;
    - (Bool) flag indicating whether score is in the top 10
    - (Bool) flag indicating whether score is a new highscore
    */
    func checkScore(scoreValue: Int, completion: ((Bool, Bool) -> Void)?) {
        
        var isHighScore = false
        var isTopTen = false
        
        // get the highscores
        let service = ServiceFactory.sharedInstance.scoreService
        service.highScores { (scores, error) in
            isTopTen = scoreValue > (scores.last?.score ?? 0) || scores.count < 10
            isHighScore = scoreValue > (scores.first?.score ?? 0)
            
            completion?(isTopTen, isHighScore)
        }
    }
    
}

// MARK: - Interactor Viper Components Api
private extension GameOverInteractor {
    var presenter: GameOverPresenterApi {
        return _presenter as! GameOverPresenterApi
    }
}
