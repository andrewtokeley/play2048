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
    
    // changing these values will flow through to the view also.
    // NOTE: currently the numbers must be the same (TileSet and View don't deal with this yet)
    let COLUMNS: Int = 4
    let ROWS: Int = 4
    
    override func setupView(data: Any) {
        if let data = data as? GameSetupData {
            view.displayHighScore(scoreValue: data.highScore)
            view.displayScore(scoreValue: 0)
            //view.displayTileSet(tileSet: TileSet(rows: ROWS, columns: COLUMNS))
            view.showNewGameOverlay(show: true)
            
            // initialise a new game, but don't show the first two tiles yet.
            interactor.newGame(tileSet: TileSet(rows: ROWS, columns: COLUMNS), showFirstTiles: false)
        }
    }
    
}

// MARK: Game Over Delegate
extension GamePresenter: GameOverDelegate {
    
    func isNewHighScore(scoreValue: Int) {
        view.displayHighScore(scoreValue: scoreValue)
    }
    
    func gameOver(didSelectOption option: GameOverOption) {
        if option == .playAgain {
            self.didSelectNewGame()
        } else if option == .close {
            self.didSelectQuitGame()
        }
    }
    
    func didSaveHighScore(scoreId: String) {
        view.showNewGameOverlay(show: true)
        router.showHighScoreModule(data: HighScoresSetupData(highlightedScoreId: scoreId))
    }
}

// MARK: - GamePresenter API
extension GamePresenter: GamePresenterApi {
        
    func gameInitialised() {
        view.displaySpinner(show: false)
    }
    
    func didSelectNewGame() {
        
        view.displaySpinner(show: true)
        view.showNewGameOverlay(show: false)
        isPlayingGame = true
        interactor.newGame(tileSet: TileSet(rows: ROWS, columns: COLUMNS), showFirstTiles: true)
        
    }
    
    func didSelectQuitGame() {
        view.showNewGameOverlay(show: true)
    }
    
    func didUpdateTileSet(tileSet: TileSet) {
        //view.displayTileSet(tileSet: tileSet)
    }
    
    func didSwipe(direction: Direction) {
        
        if isPlayingGame {
            
            interactor.moveTiles(direction: direction) { (didMove, scoreValue, highestTileValue) in
                
                // display the updated score
                self.view.displayScore(scoreValue: scoreValue)
                
                // WIN!
                if highestTileValue == self.WIN_GOAL {
                    self.isPlayingGame = false
                    
                    // Display game over dialog
                    self.router.showGameOverDialog(data: GameOverSetupData(delegate: self, scoreValue: scoreValue, highestTileValue: highestTileValue, hasWon: true))
                } else {
                    
                    // add a new tile to random space. Wait the duration of the move animation iteration.
                    if didMove {
                        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.3)) {
                            self.interactor.addNewTile { (availableMoves) in
                                if !availableMoves {
                                    
                                    // Game Over!
                                    self.isPlayingGame = false
                                    
                                    // Display game over dialog
                                    self.router.showGameOverDialog(data: GameOverSetupData(delegate: self, scoreValue: scoreValue, highestTileValue: highestTileValue, hasWon: false))
                                }
                            }
                        }
                    }
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
    
    func didMoveTile(from: GridReference, inDirection direction: Direction) {
        view.moveTile(from: from, inDirection: direction)
    }
    
    func didRemoveTile(from: GridReference) {
        view.removeTile(from: from)
    }
    
    func didChangeTileValue(newValue: Int, reference: GridReference) {
        view.changeTileValue(newValue: newValue, reference: reference)
    }
    
    func didAddTile(tile: Tile, reference: GridReference) {
        view.addTile(tile: tile, reference: reference)
    }
    
    func didRemoveAllTiles() {
        view.removeAllTiles()
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
