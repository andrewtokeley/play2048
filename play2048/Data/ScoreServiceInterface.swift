//
//  ScoreServiceInterface.swift
//  play2048
//
//  Created by Andrew Tokeley on 12/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation

protocol ScoreServiceInterface {

    func highScores(completion: (([Score], Error?) -> Void)?)
    func addScore(score: Score, completion: ((Score?, Error?) -> Void)?)
    func deleteHighScores(completion: ((Error?) -> Void)?)
    
}
