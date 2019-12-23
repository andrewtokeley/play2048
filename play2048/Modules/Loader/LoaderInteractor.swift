//
//  LoaderInteractor.swift
//  play2048
//
//  Created by Andrew Tokeley on 24/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - LoaderInteractor Class
final class LoaderInteractor: Interactor {
}

// MARK: - LoaderInteractor API
extension LoaderInteractor: LoaderInteractorApi {
    
    func getHighScores(completion: (([Score], Error?) -> Void)?) {
    
        let service = ServiceFactory.sharedInstance.scoreService
        service.highScores { (scores, error) in
            completion?(scores, error)
        }
    }

}

// MARK: - Interactor Viper Components Api
private extension LoaderInteractor {
    var presenter: LoaderPresenterApi {
        return _presenter as! LoaderPresenterApi
    }
}
