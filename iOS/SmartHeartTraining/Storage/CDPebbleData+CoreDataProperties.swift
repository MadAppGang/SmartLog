//
//  CDPebbleData+CoreDataProperties.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDPebbleData {

    @NSManaged var binaryData: NSData?
    @NSManaged var sessionID: NSNumber?
    @NSManaged var dataType: NSNumber?
    @NSManaged var id: NSNumber?

}
