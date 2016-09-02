//
//  CDSession+CoreDataProperties.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 9/2/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDSession {

    @NSManaged var activityType: NSNumber?
    @NSManaged var dateStarted: NSDate?
    @NSManaged var duration: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var markersCount: NSNumber?
    @NSManaged var notes: String?
    @NSManaged var samplesCount: NSNumber?
    @NSManaged var sent: NSNumber?
    @NSManaged var accelerometerData: NSSet?
    @NSManaged var markers: NSSet?

}
