//
//  LoaderRouter.swift
//  play2048
//
//  Created by Andrew Tokeley on 24/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

// MARK: - LoaderRouter class
final class LoaderRouter: Router {
}

// MARK: - LoaderRouter API
extension LoaderRouter: LoaderRouterApi {
}

// MARK: - Loader Viper Components
private extension LoaderRouter {
    var presenter: LoaderPresenterApi {
        return _presenter as! LoaderPresenterApi
    }
}
