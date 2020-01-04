//
//  GameOverView.swift
//  play2048
//
//  Created by Andrew Tokeley on 31/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit

//MARK: GameOverView Class
final class GameOverView: UserInterface {
    
    private let BUTTON_PLAYAGAIN = 0
    private let BUTTON_CANCEL = 1
    private let BUTTON_SAVESCORE = 2
    
    private var nameAreaHeightConstraint: NSLayoutConstraint?
    
    //MARK: - Subviews
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.8
        
        return view
    }()
        
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter name"
        textField.backgroundColor = .textFieldBackground
        textField.layer.borderColor = UIColor.textFieldBorder.cgColor
        textField.textAlignment = .center
        return textField
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .tile256
        label.font = UIFont(name: "MarkerFelt-Wide", size: 60)
        label.textAlignment = .center
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var playAgainButton: UIButton = {
        let button = UIButton()
        button.tag = BUTTON_PLAYAGAIN
        button.setTitle("You bet!", for: .normal)
        button.setTitleColor(.tile2, for: .normal)
        button.backgroundColor = .tile64
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.tag = BUTTON_CANCEL
        button.setTitle("No thanks", for: .normal)
        button.setTitleColor(.tile2, for: .normal)
        button.backgroundColor = .tile2048
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var saveScoreButton: UIButton = {
        let button = UIButton()
        button.tag = BUTTON_SAVESCORE
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.tile2, for: .normal)
        button.backgroundColor = .tile64
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Events

    @objc func buttonClick(sender: UIButton) {
        switch sender.tag {
        case BUTTON_PLAYAGAIN:
            presenter.didSelectPlayAgain()
        case BUTTON_CANCEL:
            presenter.didSelectClose()
        case BUTTON_SAVESCORE:
            presenter.didSelectSaveScore(name: nameTextField.text!, completion: nil)
        default:
            return
        }
    }
    
    //MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .clear

        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(playAgainButton)
        view.addSubview(cancelButton)
        view.addSubview(nameTextField)
        view.addSubview(saveScoreButton)
        
        setConstraints()
    }
    
    private func setConstraints() {
        
        backgroundView.autoPinEdgesToSuperviewEdges()
        
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: self.view.frame.height/3)
        
        messageLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        messageLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        messageLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        messageLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 20)
        
        nameTextField.autoPinEdge(.top, to: .bottom, of: messageLabel, withOffset: 20)
        nameTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        nameTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        nameTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        nameAreaHeightConstraint = nameTextField.autoSetDimension(.height, toSize: 40)
        
        playAgainButton.autoSetDimension(.width, toSize: 150)
        playAgainButton.autoSetDimension(.height, toSize: 50)
        playAgainButton.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 20)
        playAgainButton.autoPinEdge(toSuperviewEdge: .left, withInset: 40)
        
        cancelButton.autoSetDimension(.width, toSize: 150)
        cancelButton.autoSetDimension(.height, toSize: 50)
        cancelButton.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 20)
        cancelButton.autoPinEdge(toSuperviewEdge: .right, withInset: 40)
        
        saveScoreButton.autoAlignAxis(toSuperviewAxis: .vertical)
        saveScoreButton.autoSetDimension(.width, toSize: 150)
        saveScoreButton.autoSetDimension(.height, toSize: 50)
        saveScoreButton.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 20)
    }
}

//MARK: - TextField Delegate

extension GameOverView: UITextFieldDelegate {
    
    /// Limit the user's name to 5 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        
        let LIMIT: Int = 5
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= LIMIT
    }
}

//MARK: - GameOverView API
extension GameOverView: GameOverViewApi {
    
    func displayNextStepOptions(_ show: Bool) {
        cancelButton.alpha = show ? 1 : 0
        playAgainButton.alpha = show ? 1 : 0
    }
    
    func displayHighScoreNameEntry(_ show: Bool) {
        nameAreaHeightConstraint?.constant = show ? 30 : 0
        saveScoreButton.alpha = show ? 1 : 0
    }
    
    func displayTitle(title: String) {
        titleLabel.text = title
    }
    
    func displayMessage(message: String) {
        messageLabel.text = message
    }
    
}

// MARK: - GameOverView Viper Components API
private extension GameOverView {
    var presenter: GameOverPresenterApi {
        return _presenter as! GameOverPresenterApi
    }
    var displayData: GameOverDisplayData {
        return _displayData as! GameOverDisplayData
    }
}
