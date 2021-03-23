//
//  coreData.swift
//  CoreDataFramework
//
//  Created by Stepan Ostapenko on 20.03.2021.
//

import Foundation
import CoreData

public class CoreDataStack {
    public static let shared = CoreDataStack()
    
    private init() {}
    
    public var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.su.brf.apps.ToDoListApp2")!
        let storeUrl = containerUrl.appendingPathComponent("ToDoListApp2.sqlite")
        let description = NSPersistentStoreDescription(url: storeUrl)
        let container = NSPersistentContainer(name: "ToDoListApp2")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { storeDescription, error in
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return container
    }()
    
}
