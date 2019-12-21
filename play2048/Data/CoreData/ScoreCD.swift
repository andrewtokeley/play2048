//
//  ScoreCD.swift
//  play2048
//
//  Created by Andrew Tokeley on 14/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import CoreData

extension Score {
    
    func mapFromManagedData(data: NSManagedObject) -> Score {
        var score = Score()
        score.userName = data.value(forKey: "user") as? String
        score.dateTime = data.value(forKey: "dateTime") as? Date
        score.score = data.value(forKey: "score") as? Int
        score.highestTileValue = data.value(forKey: "highestTileValue") as? Int
        return score
    }
    
    func mapToManagedData(score: Score, data: NSManagedObject) {
        
        data.setValue(score.userName, forKeyPath: "user")
        data.setValue(score.dateTime, forKeyPath: "dateTime")
        data.setValue(score.score, forKeyPath: "score")
        data.setValue(score.highestTileValue, forKeyPath: "highestTileValue")
        
    }
}
