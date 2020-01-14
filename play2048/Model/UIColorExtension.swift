//
//  TileColour.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    // MARK: - Tile colours
    
    public class var textFieldBackground: UIColor {
        return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    }
    
    public class var textFieldBorder: UIColor {
        return .black
    }
    
    public class var tile2: UIColor {
        return UIColor(red: 249/255, green: 203/255, blue: 150/255, alpha: 1)
    }
    
    public class var tile4: UIColor {
        return UIColor(red: 246/255, green: 178/255, blue: 107/255, alpha: 1)
    }
    
    public class var tile8: UIColor {
        return UIColor(red: 230/255, green: 145/255, blue: 56/255, alpha: 1)
    }
    
    public class var tile16: UIColor {
        return UIColor(red: 182/255, green: 215/255, blue: 168/255, alpha: 1)
    }
    
    public class var tile32: UIColor {
        return UIColor(red: 147/255, green: 196/255, blue: 125/255, alpha: 1)
    }
    
    public class var tile64: UIColor {
        return UIColor(red: 106/255, green: 168/255, blue: 79/255, alpha: 1)
    }
    
    public class var tile128: UIColor {
        return UIColor(red: 234/255, green: 153/255, blue: 153/255, alpha: 1)
    }
    
    public class var tile256: UIColor {
        return UIColor(red: 224/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    public class var tile512: UIColor {
        return UIColor(red: 204/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    public class var tile1024: UIColor {
        return UIColor(red: 194/255, green: 123/255, blue: 160/255, alpha: 1)
    }
    
    public class var tile2048: UIColor {
        return UIColor(red: 166/255, green: 77/255, blue: 121/255, alpha: 1)
    }
    
    public class var gridBackground: UIColor {
        return UIColor(red: 249/255, green: 230/255, blue: 208/255, alpha: 1)
    }
    
    public class var gameBackground: UIColor {
        return UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
    }
    
    // MARK: - Instance functions
    
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
    
    // MARK: - Static functions
    
    static func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
    {
        return (b-a) * fraction + a
    }
    
    static func tileForecolour(_ value: Int) -> UIColor {
        if value < 256 {
            return .gameBackground
        }
        return .white
    }
    
    static func tileColour(_ value: Int) -> UIColor {
        switch value {
        case 2: return .tile2
        case 4: return .tile4
        case 8: return .tile8
        case 16: return .tile16
        case 32: return .tile32
        case 64: return .tile64
        case 128: return .tile128
        case 256: return .tile256
        case 512: return .tile512
        case 1024: return .tile1024
        case 2048: return .tile2048
        default: return .white
        }
    }
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}
