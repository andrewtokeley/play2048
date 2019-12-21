//
//  DocumentSerializable.swift
//  trapr
//
//  Created by Andrew Tokeley on 19/10/18.
//  Copyright © 2018 Andrew Tokeley . All rights reserved.
//

import Foundation

/**
 All types that are persisted to Firestore must implement this protocol
 */
protocol FirestoreEntity {
    
    /**
     Unique ID for the entity
     */
    var id: String? { get set }
    
    /**
     Returns a dictionary instance that represents the state of the entity
     */
    var dictionary: [String: Any] { get }
    
    /**
     Initialise the type from a dictionary of fields, typically retrieved from the database
     */
    init?(dictionary: [String: Any])
}

//protocol DocumentSerializableWithId {
//    init?(id: String, dictionary: [String: Any])
//}
