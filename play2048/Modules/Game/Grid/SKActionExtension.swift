//
//  SKActionExtension.swift
//  rollaball
//
//  Created by Andrew Tokeley on 10/01/20.
//  Copyright © 2020 Andrew Tokeley. All rights reserved.
//

import Foundation
import SpriteKit

extension SKAction {
    
    static func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 0.4, colorUpdate: ((UIColor) -> Void)?) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = UIColor(red: UIColor.lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: UIColor.lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: UIColor.lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: UIColor.lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            
            colorUpdate?(transColor)
        }
        )
    }
}
