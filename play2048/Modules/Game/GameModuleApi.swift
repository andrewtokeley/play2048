//
//  GameModuleApi.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

//import Viperit

//MARK: - GameRouter API
protocol GameRouterApi: RouterProtocol {
    
    func showHighScoreModule()
    
}

//MARK: - GameView API
protocol GameViewApi: UserInterfaceProtocol {
    
    func showNewGameOverlay(show: Bool)
    
    /// Update the display to show the given `TileSet`
    func displayTileSet(tileSet: TileSet)
    
    /// Display the score
    func displayScore(scoreValue: Int)
    
    /// Display highscore
    func displayHighScore(scoreValue: Int)
    
    /// Present game over notice
    func displayGameOverMessage(message: String)
    
    /// Display an messsage to the user. When the user dismisses the message the closure is called
    func displayMessage(title: String, message: String, completion: (() -> Void)?)
    
    func displayMessageAndGetString(title: String, message: String, completion: ((String) -> Void)?)
}

//MARK: - GamePresenter API
protocol GamePresenterApi: PresenterProtocol {
    
    /// Test function
    func didSelectHighScores()
    
    /// Called whenever the tileset has been changed
    func didUpdateTileSet(tileSet: TileSet)
    
    /// Called by interactor to advise when the score has changed
    func didUpdateScore(scoreValue: Int)
    
    /// Called when the highscore is retrieved from the data store. Not this doesn't mean it's a new high score, rather this is typically called when the app first starts.
    func didFetchHighScore(scoreValue: Int)
    
    /// View will call this to let the Presenter know about the user interaction
    func didSwipe(direction: Direction)

    /// Called to let the presenter know the game is over and there are no more moves.
    //func playerHasNoMoves()
    
    /// Called when there is a new highest value tile
    // func playerHasNewHighestValueTile(value: Int)
    
    /// The user selected to play a new game
    func didSelectNewGame()
    
    /// The user selected to quit the current game
    func didSelectQuitGame()
    
    /// Interactor will call this once a game has been initialised and is ready to play
    //func gameInitialised()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    
    /// requests the interactor to end the game and check the scores.
    //func endGame()
    
    /// Initialise new game
    func newGame(tileSet: TileSet)
    
    /**
     Moves the tiles in the given direction and returns information about the score and tileSet state.
     
     The completion closure returns three parameters,
     - (Bool) flag indicating whether there are any more moves available
     - (Int) the highest tile value
     - (Int) the score
     */
    func moveTiles(direction: Direction, completion: ((Bool, Int, Int) -> Void)?)
    
    func getHighScores(completion: (([Score], Error?) -> Void)?)
    
    /**
     Checks the current score for high score status.
     
     The closure returns two parameters;
     - (Bool) flag indicating whether score is in the top 10
     - (Bool) flag indicating whether score is a new highscore
     */
    func checkScore(scoreValue: Int, completion: ((Bool, Bool) -> Void)?)
    
    /// Save the current score. The completion closure will return the score and whether it is a high score.
    func saveScore(score: Score, completion: (() -> Void)?)
}

extension GameInteractorApi {
    func newGame(tileSet: TileSet = TileSet(rows: 4, columns: 4)) {
        self.newGame(tileSet: tileSet)
    }
}
