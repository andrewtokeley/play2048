//
//  LoaderPresenter.swift
//  play2048
//
//  Created by Andrew Tokeley on 24/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - LoaderPresenter Class
final class LoaderPresenter: Presenter {
    
    override func viewIsAboutToAppear() {
        view.displayLoadingMessage(message: "Let's get this party started...")
    }
    
    override func viewHasLoaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.view.displayLoadingMessage(message: "Getting highscores...")
            
            self.interactor.getHighScores { (scores, error) in
            
                self.view.displayLoadingMessage(message: "Are you ready yet?")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let module = AppModules.game.build()
                    
                    let data = GameSetupData(highScore: scores.first?.score ?? 0)
                    module.router.present(from: self.view.viewController, embedInNavController: false, presentationStyle: .fullScreen, transitionStyle: .crossDissolve, setupData: data, completion: nil)
                }
            }
        }
    }
}

// MARK: - LoaderPresenter API
extension LoaderPresenter: LoaderPresenterApi {
}

// MARK: - Loader Viper Components
private extension LoaderPresenter {
    var view: LoaderViewApi {
        return _view as! LoaderViewApi
    }
    var interactor: LoaderInteractorApi {
        return _interactor as! LoaderInteractorApi
    }
    var router: LoaderRouterApi {
        return _router as! LoaderRouterApi
    }
}
