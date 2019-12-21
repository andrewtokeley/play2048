//
//  ServiceFactory.swift
//  play2048
//
//  Created by Andrew Tokeley on 12/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ServiceFactory {

    static let sharedInstance = ServiceFactory()

    var runningInTestMode: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    lazy var scoreService: ScoreServiceInterface = {
        return FirestoreScoreService(firestore: Firestore.firestore(), collectionName: "Score")
    }()
    
}
