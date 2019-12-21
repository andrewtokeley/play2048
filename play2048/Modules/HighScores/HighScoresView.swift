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
    var scores = [Score]()
    
    // MARK: - Subviews
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "close"), for: .normal)
        view.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return view
    }()
    
//    lazy var titleLabel: UILabel = {
//        let view = UILabel()
//        view.font = UIFont(name: "Arial", size: 50)
//        view.textAlignment = .center
//        view.textColor = .gridBackground
//        view.isUserInteractionEnabled = true
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeading)))
//        return view
//    }()
    
    lazy var highScoreTable: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.register(UINib(nibName: "HighScoreEntryTableViewCell", bundle: nil), forCellReuseIdentifier: CELL_ID)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    // MARK: - Events
    
    @objc func didTapClose(sender: UIButton) {
        presenter.didSelectClose()
    }
    
//    @objc func tapHeading(sender: UILabel) {
//        let alert = UIAlertController(title: "Delete All High Scores", message: "Are you sure you want to do this?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
//            self.presenter.didTapHeading()
//        })
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .darkGray
        self.view.addSubview(highScoreTable)
        //self.view.addSubview(titleLabel)

        // if less than ios13
        self.view.addSubview(closeButton)
        
        setConstraints()
    }
    
    func setConstraints() {
        
//        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
//        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
//        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
//
        highScoreTable.autoPinEdge(toSuperviewEdge: .top, withInset: 60)
        highScoreTable.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        highScoreTable.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        highScoreTable.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        
        // if less than ios13
        closeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        closeButton.autoSetDimensions(to: CGSize(width: 16, height: 16))
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
            
            cell.scoreLabel.text = String(scoreValue)
            cell.scoreLabel.textColor = .gridBackground
            cell.usernameLabel.text = userValue
            cell.usernameLabel.textColor = .gridBackground
            cell.highestTileValueLabel.text = String(highestTileValue)
            cell.highestTileValueLabel.textColor = tileForegroundColor
            cell.highestTileValueLabel.backgroundColor = backgroundColor
            cell.rankLabel.text = String(indexPath.row + 1)
            cell.rankLabel.textColor = .gridBackground
            
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
    
//    func displayTitle(title: String) {
//        titleLabel.text = title
//    }
    
    func displayHighscores(scores: [Score]) {
        self.scores = scores
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
