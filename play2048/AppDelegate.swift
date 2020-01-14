//
//  AppDelegate.swift
//  play2048
//
//  Created by Andrew Tokeley on 10/12/19.
//  Copyright © 2019 Andrew Tokeley. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initalise Firebase
        FirebaseApp.configure()

        // Open first view
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let module = AppModules.loader.build()
        module.router.show(inWindow: self.window, embedInNavController: false, setupData: nil, makeKeyAndVisible: true)
        
        return true
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storedDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func savedContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

