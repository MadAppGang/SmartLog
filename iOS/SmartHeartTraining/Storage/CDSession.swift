//
//  CDSession.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreData


class CDSession: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension CDSession {
    
    @NSManaged func addMarkersObject(_ marker: CDMarker?)
    
}

extension CDSession {
    
    @NSManaged func addAccelerometerDataObject(_ accelerometerData: CDAccelerometerData?)
    
}

