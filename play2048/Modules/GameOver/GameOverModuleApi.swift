//
//  GameOverModuleApi.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

//MARK: - GameOverRouter API
protocol GameOverRouterApi: RouterProtocol {
}

//MARK: - GameOverView API
protocol GameOverViewApi: UserInterfaceProtocol {
    
    func displayNextStepOptions(_ show: Bool)
    func displayHighScoreNameEntry(_ show: Bool)
    func displayTitle(title: String)
    func displayMessage(message: String)
    
}

//MARK: - GameOverPresenter API
protocol GameOverPresenterApi: PresenterProtocol {
    func didSelectSaveScore(name: String, completion: ( (() -> Void)?))
    func didSelectPlayAgain()
    func didSelectClose()
}

//MARK: - GameOverInteractor API
protocol GameOverInteractorApi: InteractorProtocol {
    
    func endOfGameTitleAndMessage(won: Bool, isTopTen: Bool, isHighScore: Bool) -> (title: String, message: String)
    
    /**
     Checks the current score for high score status.
     
     The closure returns two parameters;
     - (Bool) flag indicating whether score is in the top 10
     - (Bool) flag indicating whether score is a new highscore
     */
    func checkScore(scoreValue: Int, completion: ((Bool, Bool) -> Void)?)
    
    /// Save the current score. The completion closure will return the score and whether it is a high score.
    func saveScore(score: Score, completion: ((Score?, Error?) -> Void)?)
    
}
