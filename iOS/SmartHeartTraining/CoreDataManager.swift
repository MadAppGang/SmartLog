//
//  CoreDataManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/15/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    static let instance = CoreDataManager()
    
    static var context: NSManagedObjectContext {
        return instance.mainContext
    }
    
    private var mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    init() {
        do {
            try prepareCoreData()
        } catch(let error) {
            print(error)
        }
    }
        
    class func save() throws {
        try saveContext(context)
    }
    
    class func saveContext(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    private func prepareCoreData() throws {
        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        let storageName = documentDirectory!.URLByAppendingPathComponent("SmartHeartTrainingStorage.sqlite")
        
        let modelURL = NSBundle.mainBundle().URLForResource("SmartHeartTraining", withExtension: "momd")
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!) else {
            throw Error.OptionalUnwrappingError("ManagedObjectModel wasn't unwrapped while preparing CoreData stack.")
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        self.persistentStoreCoordinator = persistentStoreCoordinator
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        let persistentStore = try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storageName, options: options)
        mainContext.persistentStoreCoordinator = persistentStore.persistentStoreCoordinator
    }
}