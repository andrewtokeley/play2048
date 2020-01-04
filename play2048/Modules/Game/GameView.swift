//
//  GameView.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit
//import Viperit

//MARK: GameView Class
final class GameView: UserInterface {
    
    var spinnerView: UIView?
    
    private let CELL_ID = "tile"
    private var tileSet: TileSet?
    private let GRID_SPACING: CGFloat = 5
    
    //MARK: - Subviews
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
    
    lazy var grid: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = .gridBackground
        view.register(UINib(nibName: "TileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CELL_ID)
        
        view.contentInset = UIEdgeInsets(top: GRID_SPACING, left: GRID_SPACING, bottom: GRID_SPACING, right: GRID_SPACING)
        
        view.delegate = self
        view.dataSource = self
        view.isUserInteractionEnabled = false
        return view
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
        print(sender.direction)
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
    
    // MARK: - Load View
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .gameBackground
        self.view.addSubview(grid)
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
        
        grid.autoSetDimension(.width, toSize: 0.9 * self.view.bounds.width)
        grid.autoSetDimension(.height, toSize: 0.9 * self.view.bounds.width)
        grid.autoPinEdge(.top, to: .bottom, of: highScoreTitleLabel, withOffset: 20)
        grid.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        
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
        grid.reloadData()
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

// MARK: - UICollectionView Delegate

extension GameView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sizeOfGrid = (0.9 * self.view.bounds.width)

        let size = CGFloat(tileSet!.rows)
        let sizeOfCell = (sizeOfGrid - (size + 1) * GRID_SPACING)/size

        // need to adjust so that rounding doesn't make the tiles a little too big and hence throw the layout... need a better way!
        return CGSize(width: 0.999*sizeOfCell, height: 0.999*sizeOfCell)
    }
}

extension GameView: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDataSource Delegate
extension GameView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard tileSet != nil else { return 0 }
        
        return tileSet!.rows * tileSet!.columns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for:indexPath) as! TileCollectionViewCell
        
        if let tile = tileSet?.get()[indexPath.row] {
            cell.tileValueLabel.text = String(tile.value)
            cell.tileValueLabel.textColor = tile.forecolour
            cell.tileBackgroundView.backgroundColor = tile.colour
        } else {
            // blank cell
            cell.tileValueLabel.text = ""
            cell.tileBackgroundView.backgroundColor = .white
        }
        
        return cell
    }
    
    
    
}
