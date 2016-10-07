//
//  CDMarker+CoreDataProperties.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDMarker {

    @NSManaged var dateAdded: Date?
    @NSManaged var session: CDSession?

}
