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
    
    // MARK: - Events
    
    @objc func didTapClose(sender: UIButton) {
        presenter.didSelectClose()
    }
    
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
