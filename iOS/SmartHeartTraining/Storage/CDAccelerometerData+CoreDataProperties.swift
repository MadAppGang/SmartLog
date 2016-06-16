//
//  CDAccelerometerData+CoreDataProperties.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDAccelerometerData {

    @NSManaged var dateTaken: NSDate?
    @NSManaged var x: NSNumber?
    @NSManaged var y: NSNumber?
    @NSManaged var z: NSNumber?
    @NSManaged var session: CDSession?

}
