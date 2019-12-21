//
//  CoreDataScoreService.swift
//  play2048
//
//  Created by Andrew Tokeley on 12/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import CoreData

class CoreDataScoreService: CoreDataService {
    let entityName = "Scores"
}

extension CoreDataScoreService: ScoreServiceInterface {
    
    func deleteHighScores(completion: ((Error?) -> Void)?) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
            try context.save()
            completion?(nil)
            
        } catch let error as NSError {
                completion?(DataError.ContextSaveError(error.userInfo.description))
        }
    }
    
    func highScores(completion: (([Score], Error?) -> Void)?) {
        
        var scores = [Score]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 10
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        
        do {
            let result = try context.fetch(fetchRequest)
            
            
            for data in result as! [NSManagedObject] {
            
                var score = Score()
                score.userName = data.value(forKey: "user") as? String
                score.dateTime = data.value(forKey: "dateTime") as? Date
                score.score = data.value(forKey: "score") as? Int
                score.highestTileValue = data.value(forKey: "highestTileValue") as? Int
                
                scores.append(score)
            }
            completion?(scores, nil)
        } catch let error as NSError {
            completion?(scores, DataError.ContextSaveError(error.userInfo.description))
        }
    }
    
//    func getScore(id: String, completion: ((Score?, Error?) -> Void)?) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        fetchRequest.predicate = NSPredicate(format: "gameID == $0", id)
//        fetchRequest.fetchLimit = 1
//        do {
//            if let result = try context.fetch(fetchRequest).first as? NSManagedObject {
//                
//            }
//            
//        } catch {
//            
//        }
//    }
    
    func addScore(score: Score, completion: ((Error?) -> Void)?) {
        
        // add new score
        let scoreEntity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let newScore = NSManagedObject(entity: scoreEntity, insertInto: context)
        
        newScore.setValue(score.userName, forKeyPath: "user")
        newScore.setValue(score.dateTime, forKeyPath: "dateTime")
        newScore.setValue(score.score, forKeyPath: "score")
        newScore.setValue(score.highestTileValue, forKeyPath: "highestTileValue")
        
        do {
            try context.save()
            completion?(nil)
        } catch let error as NSError {
            completion?(DataError.ContextSaveError(error.userInfo.description))
        }
        
    }
}
