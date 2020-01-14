//
//  LoaderModuleApi.swift
//  play2048
//
//  Created by Andrew Tokeley on 24/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//


//MARK: - LoaderRouter API
protocol LoaderRouterApi: RouterProtocol {
}

//MARK: - LoaderView API
protocol LoaderViewApi: UserInterfaceProtocol {
    
    func displayLoadingMessage(message: String)
}

//MARK: - LoaderPresenter API
protocol LoaderPresenterApi: PresenterProtocol {
}

//MARK: - LoaderInteractor API
protocol LoaderInteractorApi: InteractorProtocol {
    
    func authenticateUser(completion: (() -> Void)?)
    
    func getHighScores(completion: (([Score], Error?) -> Void)?)
    
}
