//
//  HighScoresView.swift
//  play2048
//
//  Created by Andrew Tokeley on 13/12/19.
//Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit

//MARK: HighScoresView Class
final class HighScoresView: UserInterface {
    
    fileprivate let CELL_ID = "cell"
    fileprivate var spinnerView: UIView?
    fileprivate var highlightedScoreId: String?
    
    var scores = [Score]()
    
    // MARK: - Subviews
    
    lazy var deleteButton: ButtonExtended = {
        let view = ButtonExtended()
        if #available(iOS 13.0, *) {
            view.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            view.setTitle("Delete", for: .normal)
        }
        view.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        view.tintColor = .tile2
        view.increaseHitAreaBy = 20
        return view
    }()
    
    lazy var closeButton: ButtonExtended = {
        let view = ButtonExtended()
        view.setImage(UIImage(named: "close"), for: .normal)
        view.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.increaseHitAreaBy = 20
        return view
    }()
        
    lazy var highScoreTable: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.register(UINib(nibName: "HighScoreEntryTableViewCell", bundle: nil), forCellReuseIdentifier: CELL_ID)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var noHighScoresMessage: UILabel = {
        let label = UILabel()
        label.textColor = .tile2
        label.textAlignment = .center
        label.text = "No highscores yet - get playing!"
        return label
    }()
    
    // MARK: - Events
    
    @objc func didTapClose(sender: UIButton) {
        presenter.didSelectClose()
    }
    
    @objc func didTapDelete(sender: UIButton) {
        guard FeatureFlags.showDeleteHighScoresOption else { return }

        let action = UIAlertController(title: "Delete High Scores?", message: "This action is only available in the Dev target. Are you sure you want to delete the high scores?", preferredStyle: .alert)
        
        action.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.presenter.didSelectDelete(completion: nil)
        }))
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            // do nothing
        }))
        
        self.present(action, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .darkGray
        self.view.addSubview(highScoreTable)
        self.view.addSubview(closeButton)
        self.view.addSubview(noHighScoresMessage)
        
        if FeatureFlags.showDeleteHighScoresOption {
            // always hide until we load highscores - even if the flag is enabled we don't want to show if there aren't any scores yet.
            deleteButton.alpha = 0
            self.view.addSubview(deleteButton)
        }

        setConstraints()
    }
    
    func setConstraints() {
   
        highScoreTable.autoPinEdge(toSuperviewEdge: .top, withInset: 60)
        highScoreTable.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        highScoreTable.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        highScoreTable.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        
        noHighScoresMessage.autoCenterInSuperviewMargins()
        
        closeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        closeButton.autoSetDimensions(to: CGSize(width: 16, height: 16))
        
        if FeatureFlags.showDeleteHighScoresOption {
            deleteButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
            deleteButton.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            deleteButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        }
    }
}

//MARK: - UITableView DataSource
extension HighScoresView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! HighScoreEntryTableViewCell

        let score = scores[indexPath.row]
        
        if let scoreValue = score.score, let userValue = score.userName, let highestTileValue = score.highestTileValue {

            let tile = Tile(value: highestTileValue)
            let backgroundColor = highestTileValue != 0 ? tile.colour : .tile32
            let tileForegroundColor = highestTileValue != 0 ? tile.forecolour : .gameBackground
            let textColour: UIColor = score.id == highlightedScoreId ? .tile64 : .gridBackground
            
            cell.scoreLabel.text = String(scoreValue)
            cell.scoreLabel.textColor = textColour
            cell.usernameLabel.text = userValue
            cell.usernameLabel.textColor = textColour
            cell.highestTileValueLabel.text = String(highestTileValue)
            cell.highestTileValueLabel.textColor = tileForegroundColor
            cell.highestTileValueLabel.backgroundColor = backgroundColor
            cell.rankLabel.text = String(indexPath.row + 1)
            cell.rankLabel.textColor = textColour
    
        }
        
        return cell
    }
}

extension HighScoresView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

//MARK: - HighScoresView API
extension HighScoresView: HighScoresViewApi {
    
    func displaySpinner(show: Bool) {
        if show {
            self.spinnerView = self.showSpinner(onView: self.view)
        } else {
            self.removeSpinner(spinnerView: self.spinnerView)
        }
    }
    
    func displayHighscores(scores: [Score], highlightedScoreId: String?) {
        
        highScoreTable.alpha = scores.count > 0 ? 1 : 0
        deleteButton.alpha = scores.count > 0 ? 1 : 0
        
        noHighScoresMessage.alpha = scores.count == 0 ? 1 : 0
        
        self.scores = scores
        self.highlightedScoreId = highlightedScoreId
        highScoreTable.reloadData()
    }
}

// MARK: - HighScoresView Viper Components API
private extension HighScoresView {
    var presenter: HighScoresPresenterApi {
        return _presenter as! HighScoresPresenterApi
    }
    var displayData: HighScoresDisplayData {
        return _displayData as! HighScoresDisplayData
    }
}
