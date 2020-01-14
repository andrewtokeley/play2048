//
//  HighScoresModuleApi.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//


//MARK: - HighScoresRouter API
protocol HighScoresRouterApi: RouterProtocol {
}

//MARK: - HighScoresView API
protocol HighScoresViewApi: UserInterfaceProtocol {
    
    func displaySpinner(show: Bool)
    
    func displayHighscores(scores: [Score], highlightedScoreId: String?)
    
}

//MARK: - HighScoresPresenter API
protocol HighScoresPresenterApi: PresenterProtocol {
    
    func didFetchHighScores(scores: [Score])
    
    func didSelectDelete(completion: (() -> Void)?)
    
    func didSelectClose()
}

//MARK: - HighScoresInteractor API
protocol HighScoresInteractorApi: InteractorProtocol {
    
    func fetchHighScores()
    
    func deleteHighscores(completion: (() -> Void)?)
}
