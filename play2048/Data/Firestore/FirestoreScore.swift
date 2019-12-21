//
//  ScoreFirestore.swift
//  play2048
//
//  Created by Andrew Tokeley on 19/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum ScoreFirestoreField: String {
    case dateTime = "dateTime"
    case scoreValue = "scoreValue"
    case username = "username"
    case highestTileValue = "highestTileValue"
}

extension Score: FirestoreEntity {
    
    var dictionary: [String : Any] {
        var result = [String: Any]()
        
        // all fields are optional so check before setting
        if let dateTime = dateTime { result[ScoreFirestoreField.dateTime.rawValue] = Timestamp(date: dateTime) }
        if let highestTileValue = highestTileValue { result[ScoreFirestoreField.highestTileValue.rawValue] = highestTileValue }
        if let userName = userName { result[ScoreFirestoreField.username.rawValue] = userName }
        if let score = score { result[ScoreFirestoreField.scoreValue.rawValue] = score }
        
        return result
    }
    
    init?(dictionary: [String : Any]) {
        self.init()

        if let dateTime = dictionary[ScoreFirestoreField.dateTime.rawValue] as? Timestamp {
            self.dateTime = dateTime.dateValue()
        }
        
        if let highestTileValue = dictionary[ScoreFirestoreField.highestTileValue.rawValue] as? Int {
            self.highestTileValue = highestTileValue
        }
        
        if let userName = dictionary[ScoreFirestoreField.username.rawValue] as? String {
            self.userName = userName
        }
        
        if let score = dictionary[ScoreFirestoreField.scoreValue.rawValue] as? Int {
            self.score = score
        }
        
    }
    
    
    
}
