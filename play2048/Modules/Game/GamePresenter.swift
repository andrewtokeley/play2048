//
//  GamePresenter.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
//import Viperit

// MARK: - GamePresenter Class
final class GamePresenter: Presenter {
    
    var isPlayingGame: Bool = false
    let WIN_GOAL = 2048
    let COLUMNS: Int = 4
    let ROWS: Int = 4
    
    override func viewHasLoaded() {
        
        view.displaySpinner(show: true)
        
        // reset the grid and highscore
        interactor.newGame(tileSet: TileSet(rows: ROWS, columns: COLUMNS), showFirstTiles: false)
        
        // add overlay to start playing
        view.showNewGameOverlay(show: true)
    }
    
    func gameInitialised() {
        view.displaySpinner(show: false)
    }
    
    func endOfGameTitleAndMessage(won: Bool, isTopTen: Bool, isHighScore: Bool) -> (title: String, message: String) {
        
        let title = won ? "You Won!" : "Game Over!"
        var message =
            won && isHighScore ? "Nice work, you reached \(String(self.WIN_GOAL)) AND got a new highscore. Wahoo!" :
                (won && isTopTen ? "Nice work, you reached \(String(self.WIN_GOAL)) AND got a top ten score" :
                    (won && !isTopTen ? "Nice work, you reached \(String(self.WIN_GOAL))! No highscore this time, sorry!" :
                        (!won && isHighScore ? "YUS, new highscore!" :
                            (!won && isTopTen ? "NOOICE, top 10 score!" : ""))))
        
        if isTopTen {
          message += "\n\nEnter your initals (up to 5 characters)"
        }
        return (title: title, message: message)
    }
    
    func processEndOfGame(scoreValue: Int, highestTileValue: Int, won: Bool) {
        
        self.isPlayingGame = false
        view.showNewGameOverlay(show: true)
        
        // check whether there's a new highscore
        self.interactor.checkScore(scoreValue: scoreValue) { (isTopTen, isHighScore) in
        
            if isHighScore {
                self.view.displayHighScore(scoreValue: scoreValue)
            }
 
            let titleAndMessage = self.endOfGameTitleAndMessage(won: won, isTopTen: isTopTen, isHighScore: isHighScore)
            let title = titleAndMessage.title
            let message = titleAndMessage.message

            if isTopTen {
                
                // need to get user's name
                self.view.displayMessageAndGetString(title: title, message: message) { (name) in
                    
                    // save the score
                    self.view.displaySpinner(show: true)
                    let score = Score(userName: name, dateTime: Date(), score: scoreValue, highestTileValue: highestTileValue)
                    self.interactor.saveScore(score: score) { (addedScore, error) in
                    
                        self.view.displaySpinner(show: false)
                        // show the high score module, highlighting the current score
                        let data = HighScoresSetupData(highlightedScoreId: addedScore?.id)
                        self.router.showHighScoreModule(data: data)
                    }
                }
            } else {
                self.view.displayMessage(title: title, message: message) {
                    // nothing left to do, this is just an info message
                }
            }

        }
    }
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
        
    func didSelectNewGame() {
        
        view.displaySpinner(show: true)
        
        // hide overlay
        view.showNewGameOverlay(show: false)
        
        // start a new game
        isPlayingGame = true
        
        interactor.newGame(tileSet: TileSet(rows: ROWS, columns: COLUMNS), showFirstTiles: true)
    }
    
    func didSelectQuitGame() {
        
    }
    
    func didUpdateTileSet(tileSet: TileSet) {
        view.displayTileSet(tileSet: tileSet)
    }
    
    func didSwipe(direction: Direction) {
        
        if isPlayingGame {
            interactor.moveTiles(direction: direction) { (availableMoves, highestTileValue, scoreValue) in
                
                // display the score
                self.view.displayScore(scoreValue: scoreValue)
                
                let won =  highestTileValue == self.WIN_GOAL
                
                if !availableMoves || won {
                    self.processEndOfGame(scoreValue: scoreValue, highestTileValue:highestTileValue, won: won)
                }
            }
        }
    }
    
    func didUpdateScore(scoreValue: Int) {
        view.displayScore(scoreValue: scoreValue)
    }
    
    func didFetchHighScore(scoreValue: Int) {
        view.displayHighScore(scoreValue: scoreValue)
    }
    
    func didSelectHighScores() {
        router.showHighScoreModule(data: nil)
    }
}

// MARK: - Game Viper Components
private extension GamePresenter {
    var view: GameViewApi {
        return _view as! GameViewApi
    }
    var interactor: GameInteractorApi {
        return _interactor as! GameInteractorApi
    }
    var router: GameRouterApi {
        return _router as! GameRouterApi
    }
}
