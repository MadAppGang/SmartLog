//
//  CDHRData+CoreDataProperties.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreData


extension CDHRData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDHRData> {
        return NSFetchRequest<CDHRData>(entityName: "CDHRData");
    }

    @NSManaged public var dateTaken: NSDate?
    @NSManaged public var heartRate: NSNumber?
    @NSManaged public var session: CDSession?

}
