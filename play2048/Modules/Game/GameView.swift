//
//  GameView.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit
import SpriteKit

//MARK: GameView Class
final class GameView: UserInterface {
    
    var spinnerView: UIView?
    private let CELL_ID = "tile"
    private var tileSet: TileSet?
    private let GRID_SPACING: CGFloat = 5
    
    var gridScene: GridScene? {
        return gridView.scene as? GridScene
    }
    
    //MARK: - Subviews
    
    lazy var gridView: SKView = {
        //print("loaded gridView")
        let view = SKView()
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        
        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif
        
        return view
    }()
    
    lazy var newGameOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        // hide initially
        view.alpha = 0
        
        let image = UIImageView(image: UIImage(named: "play"))
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newGameTap)))
        image.isUserInteractionEnabled = true
        view.addSubview(image)
        image.autoCenterInSuperview()
        return view
    }()
    
    lazy var scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 20)
        label.text = "score"
        label.textColor = .gridBackground
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 50)
        label.textColor = .gridBackground
        return label
    }()
    
    lazy var highScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 20)
        label.text = "high"
        label.textColor = .lightGray
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHighScore)))
        return label
    }()
    
    lazy var highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 50)
        label.textColor = .lightGray
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHighScore)))
        
        return label
    }()

    // MARK: - Swipes
    
    func registerSwipes() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        right.direction = .right
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        up.direction = .up
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        down.direction = .down
        
        self.view.addGestureRecognizer(left)
        self.view.addGestureRecognizer(right)
        self.view.addGestureRecognizer(up)
        self.view.addGestureRecognizer(down)
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        //print(sender.direction)
        if sender.direction == .left {
            presenter.didSwipe(direction: .left)
        }
        if sender.direction == .right {
            presenter.didSwipe(direction: .right)
        }
        if sender.direction == .up {
            presenter.didSwipe(direction: .up)
        }
        if sender.direction == .down {
            presenter.didSwipe(direction: .down)
        }
    }
    
    // MARK: - Key Presses
    
    override var keyCommands: [UIKeyCommand]? {
        
        let left = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(keyPress))
        
        let right = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(keyPress))
        
        let up = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyPress))
        
        let down = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyPress))
        
        return [left, right, up, down]
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func keyPress(sender: UIKeyCommand) {
        if let input = sender.input {
            switch input {
            case UIKeyCommand.inputLeftArrow:
                presenter.didSwipe(direction: .left)
                return
            case UIKeyCommand.inputRightArrow:
                presenter.didSwipe(direction: .right)
                return
            case UIKeyCommand.inputUpArrow:
                presenter.didSwipe(direction: .up)
                return
            case UIKeyCommand.inputDownArrow:
                presenter.didSwipe(direction: .down)
                return
            default: return
            }
        }
    }
    
    // MARK: - UIViewController overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // at this point the gridView will have been auto sized and the presented scene will have access to its bounds.
        if gridView.scene == nil {
            let scene = GridScene(dimension: 4, duration: 0.2, size: gridView.frame.size)
            gridView.presentScene(scene)
        }
        //gridView.layer.cornerRadius = 15
        newGameOverlay.layer.cornerRadius = gridView.layer.cornerRadius
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .gameBackground
        
        self.view.addSubview(gridView)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(scoreTitleLabel)
        self.view.addSubview(highScoreLabel)
        self.view.addSubview(highScoreTitleLabel)
        self.view.addSubview(newGameOverlay)
        
        registerSwipes()
        
        setContstraints()
    }
    
    private func setContstraints() {
        
        scoreLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 100)
        scoreLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20)

        scoreTitleLabel.autoPinEdge(.top, to: .bottom, of: scoreLabel, withOffset: 5)
        scoreTitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        
        highScoreLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 100)
        highScoreLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)

        highScoreTitleLabel.autoPinEdge(.top, to: .bottom, of: highScoreLabel, withOffset: 5)
        highScoreTitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        
        gridView.autoSetDimension(.width, toSize: 0.9 * self.view.bounds.width)
        gridView.autoSetDimension(.height, toSize: 0.9 * self.view.bounds.width)
        gridView.autoPinEdge(.top, to: .bottom, of: highScoreTitleLabel, withOffset: 20)
        gridView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        
        newGameOverlay.autoSetDimension(.width, toSize: 0.9 * self.view.bounds.width)
        newGameOverlay.autoSetDimension(.height, toSize: 0.9 * self.view.bounds.width)
        newGameOverlay.autoPinEdge(.top, to: .bottom, of: highScoreTitleLabel, withOffset: 20)
        newGameOverlay.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
    }
    
    // MARK: Events
    
    @objc func newGameTap(sender: UIImageView) {
        presenter.didSelectNewGame()
    }
    
    @objc func didTapHighScore(sender: UILabel) {
        self.presenter.didSelectHighScores()
    }
    
    @objc func leftButtonClick(sender: UIButton) {
        presenter.didSwipe(direction: .left)
    }
    
    @objc func rightButtonClick(sender: UIButton) {
        presenter.didSwipe(direction: .right)
    }
    
    @objc func upButtonClick(sender: UIButton) {
        presenter.didSwipe(direction: .up)
    }
    
    @objc func downButtonClick(sender: UIButton) {
        presenter.didSwipe(direction: .down)
    }
}

//MARK: - UITextFieldDelegate
extension GameView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 5
    }
}

//MARK: - GameView API
extension GameView: GameViewApi {
    
    func displaySpinner(show: Bool) {
        if show {
            self.spinnerView = self.showSpinner(onView: self.view)
        } else {
            self.removeSpinner(spinnerView: self.spinnerView)
        }
    }
    
    func showNewGameOverlay(show: Bool) {
        self.newGameOverlay.alpha = show ? 0.5 : 0
    }
    
    func displayTileSet(tileSet: TileSet) {
        self.tileSet = tileSet
        
        for r in 1...self.tileSet!.rows {
            for c in 1...self.tileSet!.columns {

                let reference = GridReference(row: r, column: c)
                if let tile = self.tileSet!.get(reference).tile {
                    self.gridScene?.addTile(tile: tile, reference: reference)
                } else {
                    self.gridScene?.removeTile(from: reference)
                }
            }
        }

    }
    
    func displayHighScore(scoreValue: Int) {
        highScoreLabel.text = String(scoreValue)
    }
    
    func displayScore(scoreValue: Int) {
        scoreLabel.text = String(scoreValue)
    }
    
    func displayMessage(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: {
           (action) in
            completion?()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func displayMessageAndGetString(title: String, message: String, completion: ((String) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.delegate = self
            textField.smartInsertDeleteType = .no
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let username = alert.textFields?.first?.text {
                completion?(username)
            } else {
                //?
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: nil))
            
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayGameOverMessage(message: String) {
        let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: { (action) in
            self.presenter.didSelectNewGame()
        }))
        alert.addAction(UIAlertAction(title: "Quit", style: .cancel, handler: {
            (action) in
            self.presenter.didSelectQuitGame()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func moveTile(from: GridReference, inDirection direction: Direction) {
        
        gridScene?.moveTile(from: from, inDirection: direction)
    }
    func removeTile(from: GridReference) {
        gridScene?.removeTile(from: from)
    }
    
    func changeTileValue(newValue: Int, reference: GridReference) {
        gridScene?.changeTileValue(newValue: newValue, at: reference)
    }
    
    func addTile(tile: Tile, reference: GridReference) {
        gridScene?.addTile(tile: tile, reference: reference)
    }
    
    func removeAllTiles() {
        gridScene?.removeAllTiles()
    }
    
}

// MARK: - GameView Viper Components API
private extension GameView {
    var presenter: GamePresenterApi {
        return _presenter as! GamePresenterApi
    }
    var displayData: GameDisplayData {
        return _displayData as! GameDisplayData
    }
}
