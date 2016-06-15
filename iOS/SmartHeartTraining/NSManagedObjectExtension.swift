//
//  NSManagedObjectExtension.swift
//  PhotoLinker
//

import CoreData

extension NSManagedObject {
    
    class func create() -> Self {
        let className = NSStringFromClass(classForCoder()).componentsSeparatedByString(".").last
        return createManagedObject(className!, context: CoreDataManager.context)
    }
    
    private class func createManagedObject<T: NSManagedObject>(entityName: String, context: NSManagedObjectContext) -> T {
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! T
    }
    
    class func all(orderedBy orderingKey: String, ascending: Bool) throws -> [NSManagedObject] {
        let className = NSStringFromClass(classForCoder()).componentsSeparatedByString(".").last
        let fetchRequest = NSFetchRequest(entityName: className!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: orderingKey, ascending: ascending)]
        return try CoreDataManager.context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
    }
    
    class func first<T: NSManagedObject>(key: String, value: AnyObject, inContext context: NSManagedObjectContext) -> T? {
        let className = NSStringFromClass(classForCoder()).componentsSeparatedByString(".").last

        let fetchRequest = NSFetchRequest(entityName: className!)
        fetchRequest.fetchLimit = 1
        
        let predicate = NSPredicate(format: "%K == %@", key, value as! NSObject) // NSObject??
        fetchRequest.predicate = predicate
        
        return (try? CoreDataManager.context.executeFetchRequest(fetchRequest)) as? T
    }
    
    func delete() {
        managedObjectContext?.deleteObject(self)
    }
}
