//
//  FirestoreScoreService.swift
//  play2048
//
//  Created by Andrew Tokeley on 19/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirestoreScoreService: FirestoreEntityService<Score> {
    
}

extension FirestoreScoreService: ScoreServiceInterface {
    
    func highScores(completion: (([Score], Error?) -> Void)?) {
        self.collection.order(by: ScoreFirestoreField.scoreValue.rawValue, descending: true).limit(to: 10).getDocuments(source: .default) { (snapshot, error) in
            
            if let error = error {
                completion?([Score](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
    }
    
    func addScore(score: Score, completion: ((Score?, Error?) -> Void)?) {
        let _ = self.add(entity: score) { (score, error) in
            completion?(score, error)
        }
    }
    
    func deleteHighScores(completion: ((Error?) -> Void)?) {
        self.highScores { (scores, error) in
            for score in scores {
                self.delete(entity: score) { (error) in
                    completion?(error)
                }
            }
        }
    }
    
    
}
