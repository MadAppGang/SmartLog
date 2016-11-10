//
//  CDSession+CoreDataProperties.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreData


extension CDSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSession> {
        return NSFetchRequest<CDSession>(entityName: "CDSession");
    }

    @NSManaged public var accelerometerDataSamplesCount: NSNumber?
    @NSManaged public var activityType: NSNumber?
    @NSManaged public var dateStarted: NSDate?
    @NSManaged public var duration: NSNumber?
    @NSManaged public var id: NSNumber?
    @NSManaged public var markersCount: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var sent: NSNumber?
    @NSManaged public var hrDataSamplesCount: NSNumber?
    @NSManaged public var accelerometerData: NSSet?
    @NSManaged public var hrData: NSSet?
    @NSManaged public var markers: NSSet?

}

// MARK: Generated accessors for accelerometerData
extension CDSession {

    @objc(addAccelerometerDataObject:)
    @NSManaged public func addToAccelerometerData(_ value: CDAccelerometerData)

    @objc(removeAccelerometerDataObject:)
    @NSManaged public func removeFromAccelerometerData(_ value: CDAccelerometerData)

    @objc(addAccelerometerData:)
    @NSManaged public func addToAccelerometerData(_ values: NSSet)

    @objc(removeAccelerometerData:)
    @NSManaged public func removeFromAccelerometerData(_ values: NSSet)

}

// MARK: Generated accessors for hrData
extension CDSession {

    @objc(addHrDataObject:)
    @NSManaged public func addToHrData(_ value: CDHRData)

    @objc(removeHrDataObject:)
    @NSManaged public func removeFromHrData(_ value: CDHRData)

    @objc(addHrData:)
    @NSManaged public func addToHrData(_ values: NSSet)

    @objc(removeHrData:)
    @NSManaged public func removeFromHrData(_ values: NSSet)

}

// MARK: Generated accessors for markers
extension CDSession {

    @objc(addMarkersObject:)
    @NSManaged public func addToMarkers(_ value: CDMarker)

    @objc(removeMarkersObject:)
    @NSManaged public func removeFromMarkers(_ value: CDMarker)

    @objc(addMarkers:)
    @NSManaged public func addToMarkers(_ values: NSSet)

    @objc(removeMarkers:)
    @NSManaged public func removeFromMarkers(_ values: NSSet)

}
