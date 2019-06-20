//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/26/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import CoreData

// a class that encapsulates the core data stack setup
class DataController {
    
    // Create and initialize the persisitant container
    let persistentContainer: NSPersistentContainer
    
    // A Computed property that returns the persistent Container view context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Initiate the persistent container with a given model name
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // Use the persistent Container to load the persistent store
    func loadPersistentStore(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
