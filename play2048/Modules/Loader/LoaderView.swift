//
//  LoaderView.swift
//  play2048
//
//  Created by Andrew Tokeley on 24/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit

//MARK: LoaderView Class
final class LoaderView: UserInterface {
    @IBOutlet weak var loadingMessageLabel: UILabel!
}

//MARK: - LoaderView API
extension LoaderView: LoaderViewApi {
    
    func displayLoadingMessage(message: String) {
        self.loadingMessageLabel.text = message
    }
}

// MARK: - LoaderView Viper Components API
private extension LoaderView {
    var presenter: LoaderPresenterApi {
        return _presenter as! LoaderPresenterApi
    }
    var displayData: LoaderDisplayData {
        return _displayData as! LoaderDisplayData
    }
}
