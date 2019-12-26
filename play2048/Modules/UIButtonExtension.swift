//
//  UIButtonExtension.swift
//  play2048
//
//  Created by Andrew Tokeley on 27/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

class ButtonExtended: UIButton {
    
    var increaseHitAreaBy: CGFloat = 10
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newArea = CGRect(x: self.bounds.origin.x - increaseHitAreaBy,
                             y: self.bounds.origin.y - increaseHitAreaBy,
                             width: self.bounds.size.width + increaseHitAreaBy * 2,
                             height: self.bounds.size.height + increaseHitAreaBy * 2)

        return newArea.contains(point)
    }
}
