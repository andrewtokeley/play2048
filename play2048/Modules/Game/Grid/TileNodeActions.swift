//
//  TileActions.swift
//  rollaball
//
//  Created by Andrew Tokeley on 10/01/20.
//  Copyright © 2020 Andrew Tokeley. All rights reserved.
//

import Foundation
import SpriteKit

class TileNodeActions {
    
    static func move(direction: Direction, distance: CGFloat, duration: TimeInterval) -> SKAction {
        
        let x = distance * CGFloat(direction.delta.columnDelta)
        let y = distance * CGFloat(direction.delta.rowDelta)

        //print("ACTION: move \(direction), x = \(x), y = \(y)")

        return SKAction.moveBy(x: x, y: y, duration: duration)
    }
    
    static func disappear(duration: TimeInterval) -> SKAction {
        return SKAction.fadeOut(withDuration: duration)
    }
    
//    static var pause: SKAction {
//        return SKAction.wait(forDuration: TileConstants.singleMoveDuration)
//    }
    
    static func changeValue(newValue: Int, duration: TimeInterval) -> SKAction {
        
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            
            if let tile = node as? TileNode {
                
                let fraction = CGFloat(elapsedTime / CGFloat(duration))
                
                let startColourComponents = tile.tileColour.toComponents()
                let endColourComponents = UIColor.tileColour(newValue).toComponents()
                let transColour = UIColor(red: UIColor.lerp(a: startColourComponents.red, b: endColourComponents.red, fraction: fraction),
                                         green: UIColor.lerp(a: startColourComponents.green, b: endColourComponents.green, fraction: fraction),
                                         blue: UIColor.lerp(a: startColourComponents.blue, b: endColourComponents.blue, fraction: fraction),
                                         alpha: UIColor.lerp(a: startColourComponents.alpha, b: endColourComponents.alpha, fraction: fraction))
                
                tile.tileColour = transColour
                
            }
        }
        )
    }    
}
