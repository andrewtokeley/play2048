//
//  GameOverPresenter.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - GameOverPresenter Class
final class GameOverPresenter: Presenter {
    private var delegate: GameOverDelegate?
    private var setUpData: GameOverSetupData?
    
    override func viewHasLoaded() {
        if let data = self.setUpData {
            self.delegate = data.delegate
            
            let spinnerContainer = self.view.viewController.showSpinner(onView: view.viewController.view)
            
            let title = data.hasWon ? "You Won!" : "Game Over!"
            view.displayTitle(title: title)
            view.displayMessage(message: "Checking high scores...")
            view.displayNextStepOptions(false)
            view.displayHighScoreNameEntry(false)
            
            interactor.checkScore(scoreValue: data.scoreValue) { (isTopTen, isHighScore) in
            
                self.view.viewController.removeSpinner(spinnerView: spinnerContainer)
                
                self.delegate?.isNewHighScore(scoreValue: data.scoreValue)
                
                let titleAndMessage = self.interactor.endOfGameTitleAndMessage(won: data.hasWon, isTopTen: isTopTen, isHighScore: isHighScore)
                
                self.view.displayNextStepOptions(!isTopTen)
                self.view.displayHighScoreNameEntry(isTopTen)
                self.view.displayMessage(message: titleAndMessage.message)
            }
        }
    }
    
    override func setupView(data: Any) {
        if let data = data as? GameOverSetupData {
            setUpData = data
        }
    }
}

// MARK: - GameOverPresenter API
extension GameOverPresenter: GameOverPresenterApi {
    
    func didSelectSaveScore(name: String, completion: ( (() -> Void)?)) {
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            // save the score
            if let setUpData = self.setUpData {
                let score = Score(id: nil, userName: name, dateTime: Date(), score: setUpData.scoreValue, highestTileValue: setUpData.highestTileValue)
                
                let spinnerContainer = self.view.viewController.showSpinner(onView: self.view.viewController.view)
                
                interactor.saveScore(score: score) { (score, error) in
                    self.view.viewController.removeSpinner(spinnerView: spinnerContainer)
                    
                    if let id = score?.id, let delegate = self.delegate {
                        self.router.dismiss(animated: false) {
                            delegate.didSaveHighScore(scoreId: id)
                        }                        
                    } else {
                        // this would only happen if the score couldn't be saved - shouldn't ever happen
                        self.view.displayMessage(message: "Do you want to play again?")
                        self.view.displayNextStepOptions(true)
                        self.view.displayHighScoreNameEntry(false)
                    }
                }
            }
        }
    }
    
    func didSelectPlayAgain() {
        delegate?.gameOver(didSelectOption: .playAgain)
        router.dismiss(animated: true, completion: nil)
    }
    
    func didSelectClose() {
        delegate?.gameOver(didSelectOption: .close)
        router.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - GameOver Viper Components
private extension GameOverPresenter {
    var view: GameOverViewApi {
        return _view as! GameOverViewApi
    }
    var interactor: GameOverInteractorApi {
        return _interactor as! GameOverInteractorApi
    }
    var router: GameOverRouterApi {
        return _router as! GameOverRouterApi
    }
}
