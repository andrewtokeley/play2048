//
//  File.swift
//  play2048
//
//  Created by Andrew Tokeley on 12/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    public var context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
}


