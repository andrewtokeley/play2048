//
//  Tile.swift
//  rollaball
//
//  Created by Andrew Tokeley on 30/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import SpriteKit

struct TileConstants {
    static var size: Int = 100
    static var singleMoveDuration = TimeInterval(0.2)
}

class TileNode: SKSpriteNode {
    
    //MARK: - Member Variables
    
    var tileValue: Int = 2 {
        didSet {
            tileValueLabel.text = String(tileValue)
        }
    }
    
    var tileSize: CGFloat = 30
    
    var tileColour: UIColor = .white {
        didSet {
            tileBackgroundNode.fillColor = tileColour
            tileBackgroundNode.strokeColor = tileColour
        }
    }
    
    var tileTextColour: UIColor = .black {
        didSet(value) {
            tileValueLabel.fontColor = value
        }
    }
    
    // MARK: - Child Nodes
    
    lazy var tileBackgroundNode: SKShapeNode = {
    
        let node = SKShapeNode()
        node.path = UIBezierPath(roundedRect: CGRect(x: -tileSize/2, y: -tileSize/2, width: tileSize, height: tileSize), cornerRadius: 0.05 * CGFloat(tileSize)).cgPath
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.fillColor = self.tileColour
        node.strokeColor = .clear
        node.lineWidth = 0
        node.zPosition = 0
        
        return node
    }()
    
    lazy var tileValueLabel: SKLabelNode = {
    
        let node = SKLabelNode(fontNamed: "AvenirNext-Bold")
        node.text = String(tileValue)
        node.fontSize = 20
        node.fontColor = self.tileTextColour
        node.zPosition = 100
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.position = CGPoint(x: 0, y:0)
        
        return node
    }()
    
    // MARK: - Initializers
    
    init(size: CGFloat, value: Int) {
        
        super.init(texture: nil, color: .clear, size: CGSize(width: tileSize, height: tileSize))

        self.tileValue = value
        self.tileSize = size
        self.tileColour = UIColor.tileColour(value)
        self.tileTextColour = UIColor.tileForecolour(value)
        
        self.addChild(tileBackgroundNode)
        self.addChild(tileValueLabel)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
