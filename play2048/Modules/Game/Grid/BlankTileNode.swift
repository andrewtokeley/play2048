//
//  BlankTileNode.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/01/20.
//  Copyright © 2020 Andrew Tokeley. All rights reserved.
//

import Foundation
import SpriteKit

class BlankTileNode: SKSpriteNode {
    private var blankTileDimension: CGFloat!
    private var blankTileInnerColor: UIColor!
    private var blankTileBorderColor: UIColor!
    
    // MARK: - SubViews
    
    lazy var blankTile: SKShapeNode = {
    
        let node = SKShapeNode()
        node.path = UIBezierPath(roundedRect: CGRect(x: -blankTileDimension/2, y: -blankTileDimension/2, width: blankTileDimension, height: blankTileDimension), cornerRadius: 0.05 * CGFloat(blankTileDimension)).cgPath
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.fillColor = self.blankTileInnerColor
        node.strokeColor = .clear
        node.lineWidth = 0
        node.zPosition = 0
        
        return node
    }()
    
    // MARK: - Initializers
    
    init(size: CGFloat) {
        
        super.init(texture: nil, color: .clear, size: CGSize(width: size, height: size))

        self.blankTileDimension = size
        self.blankTileInnerColor = UIColor.white
        self.blankTileBorderColor = UIColor.gridBackground
        
        self.addChild(blankTile)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
