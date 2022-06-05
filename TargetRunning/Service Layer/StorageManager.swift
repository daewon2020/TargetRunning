//
//  StorageManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 24.05.2022.
//

import Foundation
import CoreData

class StorageManager {
    static var shared = StorageManager()
    
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TargetRunning")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
