//
//  GameInteractor.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
//import Viperit

enum GameInteractorError: Error {
    case TileSetNotInitiated
}

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
        presenter.didRemoveAllTiles()
        
        self.tileSet?.delegate = self
        self.tileSet?.gridDelegate = self
        
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
 
    func addNewTile(completion: ((Bool) -> Void)?) {
        
        // if you call this method before you've initialised a new game, it will do nothing
        guard tileSet != nil else {
            return
        }
        
        let value = Int.random(in: 0..<10) == 0 ? 4 : 2
        self.tileSet!.addTileToRandomSpace(tile: Tile(value: value))
        completion?(self.tileSet!.canMove())
    }
    
    func moveTiles(direction: Direction, completion: ((Bool, Int, Int) -> Void)?) {
        
        // if you call this method before you've initialised a new game, it will do nothing
        guard tileSet != nil else {
            return
        }
        
        tileSet!.moveTiles(direction: direction) { (tilesDidMove) in
        
            if tilesDidMove {
                
                // Check if new highest tile value
                if let highestValue = self.tileSet?.highestTileValue {
                    if highestValue > self.currentHighestValue {
                        self.currentHighestValue = highestValue
                    }
                }
            }
            
            completion?(tilesDidMove, self.score, self.currentHighestValue)
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
        // TODO - get rid of this
    }
}

extension GameInteractor: TileSetGridDelegate {
    func tileSet(_ tileSet: TileSet, tileMovedFrom from: GridReference, inDirection direction: Direction, iteration: Int) {
        presenter.didMoveTile(from: from, inDirection: direction)
    }
    
    func tileSet(_ tileSet: TileSet, tileRemovedFrom from: GridReference, iteration: Int) {
        presenter.didRemoveTile(from: from)
    }
    
    func tileSet(_ tileSet: TileSet, tileValueChangedTo newValue: Int, at: GridReference, iteration: Int) {
        presenter.didChangeTileValue(newValue: newValue, reference: at)
    }
    
    func tileSet(_ tileSet: TileSet, tileAdded tile: Tile, reference: GridReference) {
        presenter.didAddTile(tile: tile, reference: reference)
    }

}

// MARK: - Interactor Viper Components Api
private extension GameInteractor {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
}
