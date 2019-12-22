//
//  UIViewControllerExtension.swift
//  play2048
//
//  Created by Andrew Tokeley on 22/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

extension UIViewController {

    /**
     Displays a spinner control on top of the current view controller. The spinner is added to a transparent containing view that is placed over the parent view controller. The containing view is returned and should be passed to `ViewController.removeSpinner()` to remove the spinner when ready.
     */
    func showSpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    /**
     Removes a spinner that was added (and returned) by the `showSpinner()` method.
     */
    func removeSpinner(spinnerView: UIView?) {
        DispatchQueue.main.async {
            spinnerView?.removeFromSuperview()
        }
    }
}
