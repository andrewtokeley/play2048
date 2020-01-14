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
    
    /// Display a list of high scores
    func showHighScoreModule(data: HighScoresSetupData?)
    
    /// Show the Game Over dialog
    func showGameOverDialog(data: GameOverSetupData)
}

//MARK: - GameView API
protocol GameViewApi: UserInterfaceProtocol {
    
    func displaySpinner(show: Bool)
    
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
    
    func moveTile(from: GridReference, inDirection direction: Direction)
    func removeTile(from: GridReference)
    func changeTileValue(newValue: Int, reference: GridReference)
    func addTile(tile: Tile, reference: GridReference)
    func removeAllTiles()
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
    func gameInitialised()
    
    /// Called by Interactor for each tile that has moved
    func didMoveTile(from: GridReference, inDirection direction: Direction)
    
    /// Called by Interactor for each tile that has removed
    func didRemoveTile(from: GridReference)
    
    /// Called by Interactor for each tile that has changed it's value
    func didChangeTileValue(newValue: Int, reference: GridReference)
    
    /// Called by Interactor when a new tile has been added
    func didAddTile(tile: Tile, reference: GridReference)
    
    /// Called by Interactor when all times have been removed. e.g. when a new game is initiaised.
    func didRemoveAllTiles()
}

//MARK: - GameInteractor API
protocol GameInteractorApi: InteractorProtocol {
    
    /// Initialise new game
    func newGame(tileSet: TileSet, showFirstTiles: Bool)
    
    /**
     Moves the tiles in the given direction.
     
     - Parameters:
        - completion: closure is called once the move instruction has been completed. The closure is passed a Bool flag set to whether any tiles actually moved, the score and the value of the highest tile, respectively.
     
     - Important:
     Animations associated with this move may not have completed when the completion closure is called.
     */
    func moveTiles(direction: Direction, completion: ((Bool, Int, Int) -> Void)?)
 
    /**
     Adds a new tile to the grid at a random position.

     - Parameters:
        - completion: closure is called once the tile has been added to the grid. It is passed a single `Bool` indicating whether there are any available moves left.
     
     - Important:
        Animations associated with adding the tile may not have completed whent he closure is called.
        */
    func addNewTile(completion: ((Bool) -> Void)?)

    /**
     Retrieves the latest high scores from the server.
     */
    func getHighScores(completion: (([Score], Error?) -> Void)?)
}
