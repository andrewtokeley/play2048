//
//  GameInteractor.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
//import Viperit

// MARK: - GameInteractor Class
final class GameInteractor: Interactor {
    
    private var tileSet: TileSet?
    private var score: Int = 0
    
    /// The highest valued tile in the grid
    private var currentHighestValue: Int = 2
    
    /// The all time highest score across all games
    private var currentHighScore: Int = 0
    
    /// The all time lowest score in the top 10
    private var lowestHighScore: Int = 2
    
    private var game: Game!
}

// MARK: - GameInteractor API
extension GameInteractor: GameInteractorApi {

    func newGame(tileSet: TileSet, showFirstTiles: Bool) {

        game = Game()
        
        score = 0
        
        self.tileSet = tileSet
        
        self.tileSet?.delegate = self
        
        if showFirstTiles {
            // Place two random tiles
            self.tileSet?.addTile(self.tileSet!.randomSpaceGridReference()!, tile: Tile(value: 2))
            self.tileSet?.addTile(self.tileSet!.randomSpaceGridReference()!, tile: Tile(value: 2))
        }
        
        currentHighestValue = self.tileSet?.highestTileValue ?? 2
        
        // This will clear the score to zero
        presenter.didUpdateScore(scoreValue: score)
        
        // Display the initial grid
        presenter.didUpdateTileSet(tileSet: self.tileSet!)
        
        // Get the latest highscores
        self.getHighScores { (scores, error) in
            
            if let highScore = scores.first?.score, let lowestHighScore = scores.last?.score {
                
                // remember the current highscores to help determine if it's been beaten or whether the user has hit the top 10
                self.currentHighScore = highScore
                self.lowestHighScore = lowestHighScore
                
                self.presenter.didFetchHighScore(scoreValue: highScore)
            } else {
                self.presenter.didFetchHighScore(scoreValue: 0)
                self.lowestHighScore = 2
                self.currentHighScore = 2
            }
            
            self.presenter.gameInitialised()
        }
    }
    
    func getHighScores(completion: (([Score], Error?) -> Void)?) {
    
        let service = ServiceFactory.sharedInstance.scoreService
        service.highScores { (scores, error) in
            completion?(scores, error)
        }
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
            isTopTen = scoreValue > (scores.last?.score ?? 0)
            isHighScore = scoreValue > (scores.first?.score ?? 0)
            
            completion?(isTopTen, isHighScore)
        }
    }
    
    /**
    Moves the tiles in the given direction and returns information about the score and tileSet state.
    
    The completion closure returns three parameters,
    - (Bool) flag indicating whether there are any more moves available
    - (Int) the highest tile value
    - (Int) the score
    */
    func moveTiles(direction: Direction, completion: ((Bool, Int, Int) -> Void)?) {
        
        guard tileSet != nil else {
            completion?(false, 0, 0)
            return }
        
        if (tileSet!.moveTiles(direction: direction)) {
        
            presenter.didUpdateTileSet(tileSet: tileSet!)
            
            // Check if new highest tile value
            if let highestValue = tileSet?.highestTileValue {
                if highestValue > currentHighestValue {
                    currentHighestValue = highestValue
                }
            }
            
            // Delay adding the new tile
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                // add a new tile to a random empty space, give value 2 90% of the time, otherwise 4
                let value = Int.random(in: 0..<10) == 0 ? 4 : 2
                self.tileSet!.addTileToRandomSpace(tile: Tile(value: value))
                
                self.presenter.didUpdateTileSet(tileSet: self.tileSet!)
                
                completion?(self.tileSet!.canMove(), self.currentHighestValue, self.score)
            }
        }
        
    }
}

// MARK: - TileSetDelegate

extension GameInteractor: TileSetDelegate {
        
    func tileSet(_ tileSet: TileSet, didMatchTile tile: Tile) {
        score += tile.value
        
        presenter.didUpdateScore(scoreValue: score)
    }
    
    func tileSet(_ tileSet: TileSet, highestTileValue: Int) {
        //presenter.playerHasNewHighestValueTile(value: highestTileValue)
    }
}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
