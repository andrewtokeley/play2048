//
//  GameScene.swift
//  rollaball
//
//  Created by Andrew Tokeley on 27/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import SpriteKit
import GameplayKit

/**
 SKScene that contains all the tiles and grid for the game
 */
class GridScene: SKScene {
    
    private var rows: Int = 4
    private var columns: Int = 4
    
    /// The time it takes for a tile to move one space - change this to manage the speed of the game
    private var duration = TimeInterval(0.3)
    
    // MARK: - Private properties
    
    /// The amount of space between tiles in the grid
    private let spacer: Int = 6
    
    /// Store of each `TileNode` in the grid
    private var tiles = [[TileNode?]]()
    
    /// Calculated dimension of each tile - tiles are always square
    private var tileDimension: CGFloat!
    
    // MARK: - Initialisation
    
    init(dimension: Int, duration: TimeInterval, size: CGSize) {
        super.init(size: size)
        
        self.rows = dimension
        self.columns = dimension
        self.duration = duration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        
        // initialise tiles array
        tiles = Array(repeating: Array(repeating: nil, count: rows), count: columns)
        tileDimension = (frame.width - CGFloat((columns + 1) * spacer)) / CGFloat(rows)
        
        self.scaleMode = .aspectFit
        self.backgroundColor = .clear
        
        // add blanktile nodes
        addGridBackground()
        addBlankTiles()
    }
        
    // MARK: - Helpers
    
    private func getPosition(_ reference: GridReference) -> CGPoint {
        
        var position = CGPoint(x: 0, y: 0)
        position.x = ((CGFloat(reference.column - 1) * tileDimension + CGFloat(reference.column * spacer)) + tileDimension/2)
        position.y = ((CGFloat(reference.row - 1) * tileDimension + CGFloat(reference.row * spacer)) + tileDimension/2)
        
        return position
    }
    
    // MARK: - Animations and Actions
    private func addGridBackground() {
        let node = SKShapeNode()
        
        let dimension = self.frame.width
        
        node.path = UIBezierPath(roundedRect: CGRect(x: -dimension/2, y: -dimension/2, width: dimension, height: dimension), cornerRadius: 0.02 * dimension).cgPath
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.fillColor = .gridBackground
        node.strokeColor = .clear
        node.lineWidth = 0
        node.zPosition = 0
        
        addChild(node)
    }
    
    private func addBlankTiles() {
        for r in 1...rows {
            for c in 1...columns {
                let position = getPosition(GridReference(row: r, column: c))
                let blank = BlankTileNode(size: tileDimension)
                blank.position = position
                blank.zPosition = 0
                addChild(blank)
            }
        }
    }
    
    func moveTile(from: GridReference, inDirection direction: Direction) {
        
        if let movingTile = tiles[from.row-1][from.column-1] {
            
            movingTile.run(TileNodeActions.move(direction: direction, distance: tileDimension + CGFloat(spacer), duration: self.duration))
            
            tiles[from.row - 1][from.column - 1] = nil
            tiles[from.row - 1 + direction.delta.rowDelta][from.column - 1 + direction.delta.columnDelta] = movingTile
        }
    }
    
    func removeTile(from: GridReference) {
        if let tileNode = tiles[from.row-1][from.column-1] {
            tiles[from.row - 1][from.column - 1] = nil
            tileNode.run(TileNodeActions.disappear(duration: self.duration)) {
                tileNode.removeFromParent()
            }
        }
    }
    
    func removeAllTiles() {
        for r in 1...rows {
            for c in 1...columns {
                removeTile(from: GridReference(row:r, column: c))
            }
        }
    }
    
    func changeTileValue(newValue: Int, at: GridReference) {
        
        if let tileNode = tiles[at.row-1][at.column-1] {
            
            // change the color
            tileNode.run(TileNodeActions.changeValue(newValue: newValue, duration: self.duration))
            
            // change the text value
            tileNode.tileValueLabel.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: self.duration/2),
                SKAction.run({tileNode.tileValueLabel.text = String(newValue)}),
                SKAction.fadeIn(withDuration: self.duration/2)]))
            
        }
    }    
    
    public func addTile(tile: Tile, reference: GridReference) {
        
        let tile = TileNode(size: tileDimension, value: tile.value)
        tile.position = getPosition(reference)
        tile.zPosition = 100 // always on top
        tile.alpha = 0
        
        tiles[reference.row-1][reference.column-1] = tile
        
        addChild(tile)
        
        // animate in as a pulse
        let pulseTiming = TimeInterval(0.4)
        let bulgeOut = SKAction.scale(to: 1.3, duration: pulseTiming/2)
        bulgeOut.timingMode = .easeOut
        let shrinkBack = SKAction.scale(to: 1.0, duration: pulseTiming/2)
        shrinkBack.timingMode = .easeIn
        
        tile.run(SKAction.group([
            SKAction.fadeIn(withDuration: pulseTiming),
            SKAction.sequence([
                bulgeOut,
                shrinkBack
            ])
        ]))
    }
    
}
