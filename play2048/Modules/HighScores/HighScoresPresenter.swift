//
//  HighScoresPresenter.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - HighScoresPresenter Class
final class HighScoresPresenter: Presenter {
    
    var setupData: HighScoresSetupData?
    
    override func setupView(data: Any) {
        if let data = data as? HighScoresSetupData {
            self.setupData = data
        }
    }
    
    override func viewIsAboutToAppear() {
        view.displaySpinner(show: true)
        interactor.fetchHighScores()
    }
}

// MARK: - HighScoresPresenter API
extension HighScoresPresenter: HighScoresPresenterApi {
    
    func didSelectClose() {
        router.dismiss(animated: true, completion: nil)
    }
    
    func didSelectDelete(completion: (() -> Void)?) {
        self.view.displaySpinner(show: true)
        interactor.deleteHighscores {
            self.view.displaySpinner(show: false)
            self.view.displayHighscores(scores: [Score](), highlightedScoreId: nil)
            completion?()
        }
    }
    
    func didFetchHighScores(scores: [Score]) {
        view.displaySpinner(show: false)
        view.displayHighscores(scores: scores, highlightedScoreId: self.setupData?.highlightedScoreId)
    }
}

// MARK: - HighScores Viper Components
private extension HighScoresPresenter {
    var view: HighScoresViewApi {
        return _view as! HighScoresViewApi
    }
    var interactor: HighScoresInteractorApi {
        return _interactor as! HighScoresInteractorApi
    }
    var router: HighScoresRouterApi {
        return _router as! HighScoresRouterApi
    }
}
